//
//  TPSessionService.m
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import "TPSessionService.h"
#import "TPSettings.h"
#import "TPErrorResponseSerializer.h"
#import "TPCommon.h"
#import "TPBackgroundNetworkOperationQueue.h"
#import "NSError+TPServiceErrors.h"

#import <SSKeychain/SSKeychain.h>
#import <Mantle/Mantle.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <AdSupport/ASIdentifierManager.h>


@interface TPSessionService()
- (id) initWithBaseURL:(NSURL *) baseURL
  sessionConfiguration:(NSURLSessionConfiguration *) configuration
              settings:(NSDictionary *) settings;
- (BOOL) initializeUserFromServerResponse:(NSDictionary *) responseObject withError:(NSError **) error;

@end

@implementation TPSessionService

static NSString * const kGuest = @"guest";
static NSString * const kGuestConversion = @"convert_guest";
static NSString * const kUniqueId = @"unique_id";
static NSString * const kAccountId = @"account_id";
static NSString * const kCredentials = @"credentials";
static NSString * const kEmail = @"email";


// OAuth2 Specific Keys
static NSString * const kUsernameKey = @"username";
static NSString * const kPasswordKey = @"password";
static NSString * const kGrantTypeKey = @"grant_type";
static NSString * const kClientIdKey = @"client_id";
static NSString * const kClientSecretKey = @"client_secret";
static NSString * const kRefreshTokenKey = @"refresh_token";

static NSString * const kGrantTypePassword = @"password";
static NSString * const kGrantTypeExternalAuthentication = @"external_authentication";
static NSString * const kGrantTypeRefreshToken = @"refresh_token";

static NSString * const kGuestUserId = @"guest_user_id";

// DONOT put the clientId and clientSecret in plist, it is not secure
static NSString * const kClientId = @"933282850a7e97df83b86412df262dd8dfd3842b39483a0af6ba58050862c747";
static NSString * const kClientSecret = @"09feba4f7a93be7724c2decdb9bbbb2d080c757fa142de92213d4242215ffabc";


#pragma mark - Initialization

+ (instancetype) sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    NSDictionary *settings = [TPSettings loadSettings];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sharedInstance = [[self alloc] initWithBaseURL:nil sessionConfiguration:configuration settings:settings];
  });
  return sharedInstance;
}

- (id) initWithBaseURL:(NSURL *) baseURL
  sessionConfiguration:(NSURLSessionConfiguration *) configuration
              settings:(NSDictionary *) settings {
    // Initialize from plist file which contains the API Secret.
    // Do not checkin the API secrets to Github
  
  self = [super initWithBaseURL:baseURL sessionConfiguration: configuration];
	if (self != nil) {
    _accessToken = nil;
    _refreshToken = nil;
    _accessTokenExpiresAt = nil;
    _user = nil;
    _isGuest = NO;
    _workOfflineOnly = NO;
    if (settings) {
      _keychainServiceName = [settings valueForKey:@"keychainServiceName"];
      _userServiceBaseURL = [settings valueForKey:@"userServiceBaseURL"];
      _gameServiceBaseURL = [settings valueForKey:@"gameServiceBaseURL"];
      _imageBaseURL = [settings valueForKey:@"imageBaseURL"];
      NSNumber *shouldWorkOfflineOnly = [settings valueForKey:@"workOfflineOnly"];
      if (shouldWorkOfflineOnly != nil) {
        _workOfflineOnly = [shouldWorkOfflineOnly boolValue];
      }
      NSLog(@"Configured to access: %@", _userServiceBaseURL);
    }
    self.responseSerializer = [TPErrorResponseSerializer serializer];
    [self readTokensFromKeyChain];
    [self configureClient];
  }
  return self;
}

- (id) sessionReachability {
  if (self.mockReachabilityManager) {
    return self.mockReachabilityManager;
  } else {
    return self.reachabilityManager;
  }
}

- (void) readTokensFromKeyChain {
  // This is called within initialize
  // DONOT use the property setters below:
  _accessTokenExpiresAt = [[TPSettings dateFormatter] dateFromString:[SSKeychain passwordForService:kAccessTokenExpiresAtService account:_keychainServiceName]];

  _accessToken = [SSKeychain passwordForService:kAccessTokenService account:_keychainServiceName];
  if (_accessToken) {
    [self setAuthorizationHTTPField:_accessToken];
  }
  _refreshToken = [SSKeychain passwordForService:kRefreshTokenService account:_keychainServiceName];
  _cachedUserId = [SSKeychain passwordForService:kCachedUserIdService account:_keychainServiceName];
  
  NSString *isGuestString = [SSKeychain passwordForService:kIsGuestService account:_keychainServiceName];
  if (isGuestString == nil || [isGuestString isEqualToString:@"NO"]) {
    _isGuest = NO;
  } else {
    _isGuest = YES;
  }
}

- (void) configureClient {
  AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
  
  [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  self.requestSerializer = requestSerializer;
  if (_accessToken) {
    [self setAuthorizationHTTPField:_accessToken];
  }
}

- (void) setAuthorizationHTTPField:(NSString *)accessToken {
  [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
}


#pragma mark - Session Initialization
- (void) initializeSession {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL isFirstRun = NO;
  if (![defaults objectForKey:@"firstRun"]) {
    isFirstRun = YES;
    _wasFirstRun = YES;
  } else {
    _wasFirstRun = NO;
  }
  if (isFirstRun) {
    [self initializeForFirstRun];
  } else {
    [self initializeForSubsequentRuns];
  }
  
  [self.reachabilityManager startMonitoring];

  // Now set the reachability callback to the steady state for next calls on reachability.
  @weakify(self);
  [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    @strongify(self);
    [self steadyStateReachabilityStatusChanged:status];
  }];
}

- (void) initializeForFirstRun {
  [self logout]; // Just in case we have some old/bad data
  
  // Regardless create a local guest user
  NSString *userId = [self generateUniqueUserId];
  [self initializeUserLocallyWithUserId:userId];
  
  assert(self.user != nil);
  assert(self.user.guest == YES);
  assert([self.cachedUserId isEqualToString:self.user.userId]);
  
  // Now we are properly initialized for first time
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSDate date] forKey:@"firstRun"];
  
  // This makes sure that, guest is created by system in first run and not chosen by the user
  // in the session dialog by selecting "Continue as guest"
  [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"isGuestUserChoice"];
}

- (void) initializeForSubsequentRuns {
  if (self.cachedUserId) {
    // Load the user info from disk
    self.user = [TPUser userWithUserId:self.cachedUserId];
  } else {
    // Fail fast for now, to see if this happens ever!
    NSLog(@"No user found on disk! This is ODD!");
    assert(YES);
  }
}

- (NSString *) generateUniqueUserId {
  // As per below blog:
  // http://blog.appsfire.com/udid-is-dead-openudid-is-deprecated-long-live-advertisingidentifier/
  // NSString *userId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
  // For user_id generation we will use a uuidgen, so that we can generate different users on the
  // same device. The above identifier is always unique for a given device. (Good for tracking devices
  // rather than users.
  
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  NSString *userId = CFBridgingRelease(string);
  
  return userId;
}

- (void) steadyStateReachabilityStatusChanged:(AFNetworkReachabilityStatus) status {
  if ([[self sessionReachability] isReachable]) {
    // Check first if access token exists:
    [self checkAndRenewTokensForceRefresh:NO success:^(TPSessionService *session) {} failure:^(NSError *error) {}];
  }
}

- (void) checkAndRenewTokensForceRefresh:(BOOL) forceRefresh
                                 success:(void (^)(TPSessionService *session))success
                                 failure:(void (^)(NSError *error))failure {
  if (self.workOfflineOnly) {
    return;
  }
  
  if (self.accessToken) {
    // Check if the token has expired:
    if ([self isAccessTokenExpired] || forceRefresh) {
      // We need to renew the access token
      if (self.refreshToken) {
        // We should always have a refresh token
        [self loginWithRefreshToken:self.refreshToken success:^(TPSessionService *session) {
          // update successful connection should be done in the above call
          // nothing to do here!
          success(self);
        } failure:^(NSError *error) {
          // Seems like network error, silent failure for now.
          failure(error);
        }];
      } else {
        // No refresh token found, user needs to login if they are not a guest user:
        NSError *refreshError = [NSError errorWithFailureCode:kNoRefreshTokenOrRefreshTokenExpiredError userFriendlyMessage:@"Agent needs to login again."];
        if ([self isGuest]) {
          // Guest refresh tokens should never expire!
          NSLog(@"Unnecessary guest refresh token expiration!");
          NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
          [notificationCenter postNotificationName:kUserNeedsToLoginNotification object:self];
          failure(refreshError);
        } else {
          NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
          [notificationCenter postNotificationName:kUserNeedsToLoginNotification object:self];
          failure(refreshError);
        }
      }
    } else {
      // Access token valid, we have connection
      // We are good to go!
      [self updateStatePostSuccessfulConnection];
      success(self);
    }
  } else {
    // This is a locally created guest, no token present
    // Server does not know about it, so try register:
    assert(self.user.guest == YES);
    [self registerAsGuestWithUserId:self.user.userId success:^(TPSessionService *session) {
      // update successful connection should be done in the above call
      // nothing to do here!
      success(self);
    } failure:^(NSError *error) {
      // Seems like network error, silent failure for now.
      
      // TODO: Check to make sure this is not a duplicate user registration error
      failure(error);
    }];
  }
}


- (void) updateStatePostSuccessfulConnection {
  [[TPBackgroundNetworkOperationQueue sharedInstance] tryFlush];
}

- (BOOL) isGuestUserChoice {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSNumber *isGuestUserChoice = [defaults objectForKey:@"isGuestUserChoice"];
  if (isGuestUserChoice == nil) {
    return NO;
  } else {
    return [isGuestUserChoice boolValue];
  }
}


#pragma mark - Login Info

- (BOOL) isAccessTokenExpired {
  BOOL isExpired = YES;
  NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
  
  if (_accessTokenExpiresAt && ([_accessTokenExpiresAt compare:now] == NSOrderedDescending)) {
    isExpired = NO;
  }
  
  return isExpired;
}

- (void) logout {
  [self resetTokens];
  [self resetKeyChain];
  [self clearFacebookTokenCache];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"firstRun"];
}

- (void) resetTokens {
  _accessToken = nil;
  _refreshToken = nil;
  _accessTokenExpiresAt = nil;
  _isGuest = NO;
  _cachedUserId = nil;
}

- (void) resetKeyChain {
  [SSKeychain deletePasswordForService:kAccessTokenService account:kKeyChainServiceName];
  [SSKeychain deletePasswordForService:kRefreshTokenService account:kKeyChainServiceName];
  [SSKeychain deletePasswordForService:kAccessTokenExpiresAtService account:kKeyChainServiceName];
  [SSKeychain deletePasswordForService:kIsGuestService account:kKeyChainServiceName];
  [SSKeychain deletePasswordForService:kCachedUserIdService account:kKeyChainServiceName];
}

- (void) clearFacebookTokenCache {
  if (FBSession.activeSession.state == FBSessionStateOpen
      || FBSession.activeSession.state == FBSessionStateOpenTokenExtended
      || FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
    
    // Close the session and remove the access token from the cache
    // The session state handler (in the app delegate) will be called automatically
    [FBSession.activeSession closeAndClearTokenInformation];
    NSLog(@"Facebook token cache cleared.");
  }
}

#pragma mark - Login Flow

- (void) loginWithUsername:(NSString *) username
                  password:(NSString *) password
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure {
  
  NSDictionary *fullParams = @{kUsernameKey: username,
                               kPasswordKey: password,
                               kGrantTypeKey: kGrantTypePassword,
                               kClientIdKey: kClientId,
                               kClientSecretKey: kClientSecret
                               };
  
  @weakify(self);
  [self POST:[self oauthURLRoot] parameters:fullParams
     success:^(NSURLSessionDataTask *task, id responseObject) {
       @strongify(self);
      [self handleSuccessfulResponse:responseObject success:success failure:failure];
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
       failure(error);
     }];
  
}

- (void) loginWithAuthHash:(NSDictionary *) authHash
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure {
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:authHash];
  [params setObject:kClientId forKey:kClientIdKey];
  [params setObject:kClientSecret forKey:kClientSecretKey];
  [params setObject:kGrantTypeExternalAuthentication forKey:kGrantTypeKey];
  
  [params setObject:[authHash objectForKey:kCredentials] forKey:kPasswordKey];
  [params setObject:[authHash objectForKey:kAccountId] forKey:kUsernameKey];

  @weakify(self);
  [self POST:[self oauthURLRoot] parameters:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
       @strongify(self);
       [self handleSuccessfulResponse:responseObject success:success failure:failure];
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
       failure(error);
     }];
}

- (void) loginWithRefreshToken:(NSString *) refreshToken
                       success:(void (^)(TPSessionService *session))success
                       failure:(void (^)(NSError *error))failure {
  NSParameterAssert(refreshToken != nil);
  NSDictionary *fullParams = @{kRefreshTokenKey: refreshToken,
                               kGrantTypeKey: kGrantTypeRefreshToken,
                               kClientIdKey: kClientId,
                               kClientSecretKey: kClientSecret
                               };
  @weakify(self);
  [self POST:[self oauthURLRoot] parameters:fullParams
     success:^(NSURLSessionDataTask *task, id responseObject) {
       @strongify(self);
       [self handleSuccessfulResponse:responseObject success:success failure:failure];
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
       failure(error);
     }];
}


#pragma mark - Registration Flow

- (void) registerAsGuestWithUserId:(NSString *) userId
                           success:(void (^)(TPSessionService *session))success
                           failure:(void (^)(NSError *error))failure {
  NSParameterAssert(userId != nil);
  NSDictionary *params = @{kGuest: @YES,
                           kGuestConversion: @NO,
                           kUniqueId: userId,
                           kClientIdKey: kClientId,
                           kClientSecretKey: kClientSecret};
  NSLog(@"Registering at %@", [self userURLRoot]);
  @weakify(self);
  [self POST:[self userURLRoot] parameters:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
       @strongify(self);
       [self handleSuccessfulResponse:responseObject success:success failure:failure];
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
       failure(error);
     }];
}

- (void) registerWithEmail:(NSString *) email
                  password:(NSString *) password
          convertFromGuest:(BOOL) convertFromGuest
               guestUserId:(NSString *) guestUserId
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure {
  
  NSString *userId = nil;
  if (convertFromGuest && guestUserId) {
    userId = guestUserId;
  } else {
    userId = [self generateUniqueUserId];
  }
  NSDictionary *params = @{kCredentials: password,
                           kAccountId: email,
                           kClientIdKey: kClientId,
                           kClientSecretKey: kClientSecret,
                           kEmail: email,
                           kUniqueId: userId,
                           kGuestConversion: @(convertFromGuest)
                           };
  @weakify(self);
  [self POST:[self userURLRoot] parameters:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
       @strongify(self);
       [self handleSuccessfulResponse:responseObject success:success failure:failure];
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
       failure(error);
     }];
}

- (void) registerWithAuthHash:(NSDictionary *) authHash
             convertFromGuest:(BOOL) convertFromGuest
                  guestUserId:(NSString *) guestUserId
                      success:(void (^)(TPSessionService *session))success
                      failure:(void (^)(NSError *error))failure {

  NSString *userId = nil;
  if (convertFromGuest && guestUserId) {
    userId = guestUserId;
  } else {
    userId = [self generateUniqueUserId];
  }

  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:authHash];
  [params setObject:kClientId forKey:kClientIdKey];
  [params setObject:kClientSecret forKey:kClientSecretKey];
  [params setObject:userId forKey:kUniqueId];
  [params setObject:@(convertFromGuest) forKey:kGuestConversion];
  @weakify(self);
  [self POST:[self userURLRoot] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
    @strongify(self);
    [self handleSuccessfulResponse:responseObject success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void) handleSuccessfulRegisterResponse:(id) responseObject
                                  success:(void (^)(TPSessionService *session))success
                                  failure:(void (^)(NSError *error))failure {
  NSError *error;
  BOOL isInitialized = [self initializeUserFromServerResponse:responseObject withError:&error];
  if (!isInitialized) {
    failure(error);
  } else {
    assert(self.user != nil);
    [self updateStatePostSuccessfulConnection];
    success(self);
  }
}


#pragma mark - Handling User Creation

- (void) handleSuccessfulResponse:(id) responseObject
                          success:(void (^)(TPSessionService *session))success
                          failure:(void (^)(NSError *error))failure {
  NSError *error;
  BOOL isInitialized = [self initializeUserFromServerResponse:responseObject withError:&error];
  if (!isInitialized) {
    failure(error);
  } else {
    assert(self.user != nil);
    [self updateStatePostSuccessfulConnection];
    success(self);
  }
}


- (void) initializeUserLocallyWithUserId:(NSString *) userId {
  NSParameterAssert(userId != nil);
  assert(userId != nil);
  self.user = [TPUser userWithUserId:userId];
  
  self.cachedUserId = userId;
  self.isGuest = self.user.guest;
}

- (BOOL) initializeUserFromServerResponse:(NSDictionary *) responseObject withError:(NSError **) error {
  if (responseObject == nil || ![responseObject isKindOfClass:[NSDictionary class]]) {
    if (error != nil) {
      *error = [NSError errorWithFailureCode:kUnknownServerResponse
                         userFriendlyMessage:@"Server did not respond correctly!"];
    }
    return NO;
  }

  [self retrieveUserAndTokenFromResponse:responseObject];
  
  self.cachedUserId = self.user.userId;
  self.isGuest = self.user.guest;

  return YES;
}

- (void) retrieveUserAndTokenFromResponse:(NSDictionary *) responseObject {
  NSDictionary *dataResponse = [responseObject valueForKey:@"data"];
  [self retrieveTokenInfoFromResponse:dataResponse];
  [self retrieveUserFromResponse:dataResponse];
}

- (void) retrieveTokenInfoFromResponse:(NSDictionary *) dataResponse {
  NSDictionary *tokenInfo = [dataResponse objectForKey:@"token"];
  self.accessToken = [tokenInfo objectForKey:kOAuthResponseAccessToken];
  self.refreshToken = [tokenInfo objectForKey:kOAuthResponseRefreshToken];
  self.accessTokenExpiresAt = [NSDate dateWithTimeIntervalSinceNow:[[tokenInfo objectForKey:kOAuthResponseExpiresIn] doubleValue]];
}

- (void) retrieveUserFromResponse:(id) dataResponse {
  NSDictionary *userDict = [dataResponse valueForKey:@"user"];
  self.user = [TPUser userWithDictionary:userDict];
}

#pragma mark - Access Token Info

- (void) setAccessToken:(NSString *)accessToken {
  if (![accessToken isEqualToString:_accessToken]) {
    _accessToken = [accessToken copy];
    [self setAuthorizationHTTPField:_accessToken];
    [SSKeychain setPassword:_accessToken forService:kAccessTokenService account:self.keychainServiceName];
  }
}

- (void) setRefreshToken:(NSString *)refreshToken {
  if (![refreshToken isEqualToString:_refreshToken]) {
    _refreshToken = [refreshToken copy];
    [SSKeychain setPassword:_refreshToken forService:kRefreshTokenService account:self.keychainServiceName];
  }
}

- (void) setAccessTokenExpiresAt:(NSDate *)expiresAt {
  if (expiresAt != _accessTokenExpiresAt) {
    _accessTokenExpiresAt = expiresAt;
    NSString *persistedDate = [[TPSettings dateFormatter] stringFromDate:_accessTokenExpiresAt];
    [SSKeychain setPassword:persistedDate forService:kAccessTokenExpiresAtService account:self.keychainServiceName];
  }
}

- (void) setIsGuest:(BOOL)isGuest {
  if (isGuest != _isGuest) {
    _isGuest = isGuest;
    NSString *isGuestString = isGuest ? @"YES" : @"NO";
    [SSKeychain setPassword:isGuestString forService:kIsGuestService account:self.keychainServiceName];
  }
}

- (void) setCachedUserId:(NSString *)cachedUserId {
  if (![_cachedUserId isEqualToString:cachedUserId]) {
    _cachedUserId = [cachedUserId copy];
    [SSKeychain setPassword:_cachedUserId forService:kCachedUserIdService account:self.keychainServiceName];
  }
}

#pragma mark - URL endpoints

- (NSString *) userURLRoot {
  return [NSString stringWithFormat:@"%@%@", self.userServiceBaseURL, kTPUserUrlRoot];
}

- (NSString *) oauthURLRoot {
  return [NSString stringWithFormat:@"%@%@", self.userServiceBaseURL, kTPOAuthUrlRoot];
}

#pragma mark - Error handling helpers
- (BOOL) resolveUnauthorizedAccessError:(NSError *) error
                                success:(void (^)(TPSessionService *session))success
                                failure:(void (^)(NSError *error))failure {
  BOOL willResolve = NO;
  if (error.failureCode == kUnauthorizedAccessError) {
    [self checkAndRenewTokensForceRefresh:YES success:success failure:failure];
    willResolve = YES;
  }
  return willResolve;
}

- (BOOL) isNotReachableCallFailure:(void (^)(NSError *error))failure {
  BOOL isNotReachable = NO;
  if (![[self sessionReachability] isReachable]) {
    isNotReachable = YES;
    NSError *error = [NSError errorWithFailureCode:kServerIsNotReachable userFriendlyMessage:@"TidePool servers are not reachable."];
    failure(error);
  }
  return isNotReachable;
}



@end
