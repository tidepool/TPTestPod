//
//  TPSessionServiceTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 2/3/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TPTestUtils.h"
#import "TPCommon.h"
#import <TPServices/TPSettings.h>
#import <TPServices/TPSessionService.h>
#import <SSKeychain/SSKeychain.h>

static NSString * const kUniqueId = @"unique_id";
static NSString * const kGuest = @"guest";
static NSString * const kPrimaryAccount = @"primary_account";
static NSString * const kAccountId = @"account_id";
static NSString * const kCredentials = @"credentials";
static NSString * const kDisplayName = @"display_name";
static NSString * const kName = @"name";
static NSString * const kImage = @"image";
static NSString * const kEmail = @"email";
static NSString * const kGender = @"gender";
static NSString * const kDateOfBirth = @"date_of_birth";
static NSString * const kAge = @"age";
static NSString * const kEducation = @"education";
static NSString * const kHandedness = @"handedness";
static NSString * const kCity = @"city";
static NSString * const kState = @"state";
static NSString * const kCountry = @"country";
static NSString * const kLocale = @"locale";
static NSString * const kProfilePhoto = @"profile_photo_url";

@interface TPSessionServiceTests : XCTestCase
@end

@implementation TPSessionServiceTests

#pragma mark - Setup

- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
//  [TPTestUtils resetKeyChain];
}

- (void) tearDown {
  // Put teardown code here; it will be run once, after the last test case.
  [super tearDown];
  [TPTestUtils resetKeyChain];
  [TPTestUtils cleanupUserFolders];
}

#pragma mark - Unit Tests

- (void) testLoadingSettings {
  TPSessionService *session = [TPSessionService sharedInstance];
  
  expect(session.userServiceBaseURL).equal(@"http://user-service.dev/");
}

- (void) testPersistExpiresAtInDevice {
  TPSessionService *session = [TPSessionService sharedInstance];

  NSDictionary *tokenInfo = @{  @"access_token": @"tVVtCujNEFASTORkZCrddrMwf51F3TfRtknistZtTPQfFI0c6O7B2RpjsVZUX5WMFXU11YSGGItDDPkR_U9NtA==",
                                @"token_type": @"Bearer",
                                @"expires_in": @(599.9925949573517),
                                @"refresh_token": @"xlRz_070-2yFeMR1-Bl4weGjHvJ-GnzMU4T5E3h1nesHbb8jhfkSlBqaIHixE7ZkqM4ZTy61vmy1uI592Vk1xA=="
                              };
  
  NSDate *expiresAt = [NSDate dateWithTimeIntervalSinceNow:[[tokenInfo objectForKey:kOAuthResponseExpiresIn] doubleValue]];
  expect(expiresAt).notTo.beNil;
  
  session.accessTokenExpiresAt = expiresAt;

  NSString *expiresAtString = [SSKeychain passwordForService:kAccessTokenExpiresAtService account:kKeyChainServiceName];
  expect(expiresAtString).notTo.beNil;
  
  NSDate *expectedExpiresAt = [[TPSettings dateFormatter] dateFromString:[SSKeychain passwordForService:kAccessTokenExpiresAtService account:kKeyChainServiceName]];
  expect(expectedExpiresAt).notTo.beNil;
  
  [TPTestUtils resetKeyChain];
}

#pragma mark - Integration - Building Blocks

//- (void) testRegisterUserAsGuestWhenServerReachable {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  TPSessionService *sessionService = [TPSessionService sharedInstance];
//  
//  __block TPUser *guestUser = nil;
//  __block TPSessionService *newSession = nil;
//  __block NSString *errorDesc;
//  __block BOOL folderExists = NO;
//  
//  [sessionService createGuestLocallyAndTryRegisterSuccess:^(TPSessionService *session) {
//    guestUser = session.user;
//    newSession = session;
//    folderExists = [TPTestUtils folderExistsWithName:guestUser.userId];
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  expect(guestUser.guest).will.equal(true);
//  expect(guestUser.userId).willNot.beNil;
//  expect(newSession.isGuest).will.equal(true);
//  expect(newSession.retryGuestRegistration).will.equal(false);
//  expect(folderExists).will.equal(true);
//}
//
//- (void) testRegisterUserAsGuestWhenServerNotReachable {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  TPSessionService *sessionService = [TPSessionService sharedInstance];
//  
//  sessionService.userServiceBaseURL = @"http://foo.dev"; //Fake endpoint
//  __block TPUser *guestUser = nil;
//  __block TPSessionService *newSession = nil;
//  __block NSString *errorDesc;
//  [sessionService createGuestLocallyAndTryRegisterSuccess:^(TPSessionService *session) {
//    guestUser = session.user;
//    newSession = session;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  expect(guestUser.guest).will.equal(true);
//  expect(guestUser.userId).willNot.beNil;
//  expect(newSession.isGuest).will.equal(true);
//  expect(newSession.retryGuestRegistration).will.equal(true);
//}
//
//- (void) testRegisterUserAsGuestWhenGuestIdExistsLocally {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  TPSessionService *sessionService = [TPSessionService sharedInstance];
//  sessionService.isGuest = YES;
//  sessionService.cachedUserId = @"a5b5c5d5e5f5";
//  
//  __block TPUser *guestUser = nil;
//  __block TPSessionService *newSession = nil;
//  __block NSString *errorDesc;
//  [sessionService createGuestLocallyAndTryRegisterSuccess:^(TPSessionService *session) {
//    guestUser = session.user;
//    newSession = session;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  expect(guestUser.guest).will.equal(true);
//  expect(guestUser.userId).will.equal(@"a5b5c5d5e5f5");
//  expect(newSession.isGuest).will.equal(true);
//  expect(newSession.retryGuestRegistration).will.equal(false);
//}


// This test requires the user-service to be restarted, otherwise will give
// "User Account Already Exists" error.

- (void) testRegisterUserWithCredentials {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block TPUser *registeredUser;
  __block NSString *errorDesc;
  [session registerWithEmail:@"test_user@example.com"
                    password:@"12345678"
            convertFromGuest:NO
                 guestUserId:nil
                     success:^(TPSessionService *session) {
    registeredUser = session.user;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  expect(registeredUser.email).will.equal(@"test_user@example.com");
  expect(registeredUser.guest).will.equal(NO);
}

- (void) testRegisterUserWithExistingUsername {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *email;
  __block NSString *failureCode;
  __block NSString *message;
  [session registerWithEmail:@"spec_user1@example.com"
                    password:@"12345678"
            convertFromGuest:NO
                 guestUserId:nil
                     success:^(TPSessionService *session) {
    email = session.user.email;
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(failureCode).will.equal([NSNumber numberWithInteger:1005]);
  expect(message).will.equal(@"User account already exists.");
}

- (void) testConvertGuestUserToRegisteredUser {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  TPSessionService *session = [TPSessionService sharedInstance];

  __block TPUser *registeredUser;
  __block NSString *errorDesc;
  [session registerWithEmail:@"converted_user@example.com"
                    password:@"12345678"
            convertFromGuest:YES
                 guestUserId:@"guest_user_id"
                     success:^(TPSessionService *session) {
                       registeredUser = session.user;
                     } failure:^(NSError *error) {
                       errorDesc = [error description];
                     }];
  expect(registeredUser.email).will.equal(@"converted_user@example.com");
  expect(registeredUser.guest).will.equal(NO);
  expect(registeredUser.userId).will.equal(@"guest_user_id");
}

- (void) testLoginWithCredentials {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *errorDesc;
  __block TPSessionService *newSession;
  __block TPUser *user;
  
  [session loginWithUsername:@"spec_user1@example.com"
                    password:@"12345678"
                     success:^(TPSessionService *session) {
    newSession = session;
    user = session.user;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  expect(user.email).will.equal(@"spec_user1@example.com");
  expect(session.isGuest).will.equal(false);
  expect(session.cachedUserId).equal(user.userId);
}

- (void) testDenyLoginForWrongPassword {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *email;
  __block NSString *failureCode;
  __block NSString *message;
  [session loginWithUsername:@"spec_user1@example.com"
                    password:@"1234567"
                     success:^(TPSessionService *session) {
    email = session.user.email;
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(failureCode).will.equal([NSNumber numberWithInteger:1000]);
  expect(message).will.equal(@"User credentials are incorrect.");
}

- (void) testDenyLoginForWrongUsername {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *email;
  __block NSString *failureCode;
  __block NSString *message;
  [session loginWithUsername:@"spec_usr1@example.com"
                    password:@"12345678"
                     success:^(TPSessionService *session) {
    email = session.user.email;
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(failureCode).will.equal([NSNumber numberWithInteger:1001]);
  expect(message).will.equal(@"User does not exist.");
}

- (void) testLoginWithRefreshToken {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *failureCode;
  __block NSString *message;
  [session loginWithRefreshToken:@"Valid12345678"
                         success:^(TPSessionService *session) {
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(session.refreshToken).will.equal(@"Valid12345678");
}

- (void) testLoginWithExpiredRefreshToken {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *failureCode;
  __block NSString *message;
  [session loginWithRefreshToken:@"ExpiredRefresh12345678"
                         success:^(TPSessionService *session) {
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(failureCode).will.equal([NSNumber numberWithInteger:1000]);
  expect(message).will.equal(@"refresh_token expired.");
}

- (void) testLoginWithInvalidRefreshToken {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  __block NSString *failureCode;
  __block NSString *message;
  [session loginWithRefreshToken:@"NoTokenLikeThisExist"
                         success:^(TPSessionService *session) {
  } failure:^(NSError *error) {
    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
    message = [[error userInfo] valueForKey:kTPUserFriendlyErrorMessage];
  }];
  expect(failureCode).will.equal([NSNumber numberWithInteger:1000]);
  expect(message).will.equal(@"refresh_token not found.");
}

#pragma mark - Integration - Session Managament

- (void) testInitializeSession {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];

//  TPSessionService *sessionService = [TPSessionService sharedInstance];
//  
//  __block NSString *failureCode;
//  __block NSString *userId;
//  __block TPSessionService *newSession;
//  __block BOOL serverResponded = NO;
//  
//  [sessionService trySessionInitializationSuccess:^(TPSessionService *session) {
//    serverResponded = YES;
//    userId = session.user.userId;
//    newSession = session;
//  } failure:^(NSError *error) {
//    serverResponded = YES;
//    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
//  }];
//  
//  while(!serverResponded) {
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//  }
//
//  expect(userId).willNot.beNil;
//  expect(newSession.retryGuestRegistration).will.equal(NO);
//  expect(newSession.isGuest).will.equal(YES);
//  expect(newSession.cachedUserId).will.equal(userId);
}

- (void) testInitializeSessionWhenLoggedInUserExists {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
//  TPSessionService *session = [TPSessionService sharedInstance];
//  [TPTestUtils loginTestUser];
//  expect(session.user.userId).to.equal(@"a2b2c3d4e5");
//  __block NSString *failureCode;
//  __block NSString *userId;
//  __block TPSessionService *newSession;
//  __block BOOL serverResponded = NO;
//
//  [session trySessionInitializationSuccess:^(TPSessionService *session) {
//    newSession = session;
//    serverResponded = YES;
//    userId = session.user.userId;
//  } failure:^(NSError *error) {
//    serverResponded = YES;
//    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
//  }];
//  
//  while(!serverResponded) {
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//  }
//
//  expect(userId).will.equal(@"a2b2c3d4e5");
//  expect(newSession.retryGuestRegistration).will.equal(NO);
//  expect(newSession.isGuest).will.equal(NO);
//  expect(newSession.cachedUserId).will.equal(@"a2b2c3d4e5");
//  [session logout];
}

- (void) testInitializeSessionWhenLoggedInUserExistsButTokenExpired {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
//  TPSessionService *session = [TPSessionService sharedInstance];
//  [TPTestUtils loginTestUserWithExpiredAccessTokenInSeconds:0.0];
//  expect(session.user.userId).to.equal(@"f1g2h3i4j6");
//  
//  __block NSString *failureCode;
//  __block NSString *userId;
//  __block TPSessionService *newSession;
//  __block BOOL serverResponded = NO;
//  
//  [session trySessionInitializationSuccess:^(TPSessionService *session) {
//    serverResponded = YES;
//    userId = session.user.userId;
//    newSession = session;
//  } failure:^(NSError *error) {
//    serverResponded = YES;
//    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
//  }];
//
//  while(!serverResponded) {
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//  }
//
//  expect(userId).will.equal(@"f1g2h3i4j6");
//  expect(newSession.retryGuestRegistration).will.equal(NO);
//  expect(newSession.isGuest).will.equal(NO);
//  expect(newSession.cachedUserId).will.equal(@"f1g2h3i4j6");
//
//  [session logout];
}

- (void) testInitializeSessionWhenLoggedInUserExistsButTokenExpiredOnTheServer {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
//  TPSessionService *session = [TPSessionService sharedInstance];
//  [TPTestUtils loginTestUserWithExpiredAccessTokenInSeconds:1200.0];
//  
//  __block NSString *failureCode;
//  __block NSString *userId;
//  __block TPSessionService *newSession;
//  __block BOOL serverResponded = NO;
//  
//  [session trySessionInitializationSuccess:^(TPSessionService *session) {
//    serverResponded = YES;
//    userId = session.user.userId;
//    newSession = session;
//  } failure:^(NSError *error) {
//    serverResponded = YES;
//    failureCode = [[error userInfo] valueForKey:kTPFailureCode];
//  }];
//  
//  while(!serverResponded) {
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//  }
//  
//  expect(userId).will.equal(@"f1g2h3i4j6");
//  expect(newSession.retryGuestRegistration).will.equal(NO);
//  expect(newSession.isGuest).will.equal(NO);
//  expect(newSession.cachedUserId).will.equal(@"f1g2h3i4j6");
//  [session logout];
}

@end
