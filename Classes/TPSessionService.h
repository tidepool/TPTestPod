//
//  TPSessionService.h
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <FacebookSDK/Facebook.h>
#import "TPErrorResponseSerializer.h"
#import "TPUser.h"
#import "TPCommon.h"

static NSString * const kUserNeedsToLoginNotification = @"UserNeedsToLoginNotification";
static NSString * const kSessionInitializedNotification = @"SessionInitializedNotification";

static NSString * const kOAuthResponseAccessToken = @"access_token";
static NSString * const kOAuthResponseRefreshToken = @"refresh_token";
static NSString * const kOAuthResponseExpiresIn = @"expires_in";

@class TPSessionService;

@interface TPSessionService : AFHTTPSessionManager
+ (id)sharedInstance;

@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, readonly) NSString *keychainServiceName;
@property(nonatomic, copy) NSString *userServiceBaseURL;
@property(nonatomic, copy) NSString *gameServiceBaseURL;
@property(nonatomic, copy) NSString *imageBaseURL;

@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, strong) NSDate *accessTokenExpiresAt;
@property(nonatomic, strong) TPUser *user;
@property(nonatomic, assign) BOOL isGuest;

@property(nonatomic, assign) BOOL workOfflineOnly;

@property(nonatomic, strong) id mockReachabilityManager;

// The default user persisted firstRun setting is reset during initialization
// The clients of the API can access this later on to have access to that
// The next time the app starts again this will be false
// The value is only reset when the initializeSession is called.
@property(nonatomic, assign, readonly) BOOL wasFirstRun;
@property(nonatomic, copy) NSString *cachedUserId;

- (void) registerWithEmail:(NSString *) email
                  password:(NSString *) password
          convertFromGuest:(BOOL) convertFromGuest
               guestUserId:(NSString *) guestUserId
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure;

- (void) registerWithAuthHash:(NSDictionary *) authHash
             convertFromGuest:(BOOL) convertFromGuest
                  guestUserId:(NSString *) guestUserId
                      success:(void (^)(TPSessionService *session))success
                      failure:(void (^)(NSError *error))failure;

- (void) loginWithUsername:(NSString *) username
                  password:(NSString *) password
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure;

- (void) loginWithAuthHash:(NSDictionary *) authHash
                   success:(void (^)(TPSessionService *session))success
                   failure:(void (^)(NSError *error))failure;

- (void) loginWithRefreshToken:(NSString *) refreshToken
                       success:(void (^)(TPSessionService *session))success
                       failure:(void (^)(NSError *error))failure;

- (void) logout;

- (NSString *) userURLRoot;
- (NSString *) oauthURLRoot;

- (void) initializeSession;

- (BOOL) resolveUnauthorizedAccessError:(NSError *) error
                                success:(void (^)(TPSessionService *session))success
                                failure:(void (^)(NSError *error))failure;
- (BOOL) isNotReachableCallFailure:(void (^)(NSError *error))failure;
@end
