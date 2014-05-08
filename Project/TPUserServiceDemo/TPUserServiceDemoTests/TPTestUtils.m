//
//  TPTestUtils.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 3/6/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import "TPTestUtils.h"
#import <TPServices/TPSessionService.h>

static NSString * const kUniqueId = @"unique_id";
static NSString * const kGuest = @"guest";
static NSString * const kPrimaryAccount = @"primary_account";
static NSString * const kAccountId = @"account_id";
static NSString * const kEmail = @"email";

static NSString * const kOperationQueueFilename = @"TPOperationQueue.plist";
static NSString * const kOperationsMarkedForRemovalFilename = @"TPOperationsMarkedForRemoval.plist";

@implementation TPTestUtils

+ (NSString *) dataFilePath:(NSString *) filename {
  NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *filePath = [rootPath stringByAppendingPathComponent:filename];
  
  return filePath;
}

+ (void) mockSessionReachabilityWithReachabilityStatus:(BOOL) isReachable {
  TPSessionService *session = [TPSessionService sharedInstance];
  id mockReachabilityManager = [OCMockObject mockForClass:[AFNetworkReachabilityManager class]];
  [[[mockReachabilityManager stub] andReturnValue:@(isReachable)] isReachable];
  session.mockReachabilityManager = mockReachabilityManager;
}

+ (void) removeFileAtFilePath:(NSString *) filePath {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error;
  [fileManager removeItemAtPath:filePath error:&error];
}

+ (void) resetKeyChain {
  TPSessionService *session = [TPSessionService sharedInstance];
  [session logout];
}

+ (void) resetGameAggregateResultLocalDataForGame:(NSString *) gameUniqueName {
  NSString *filePath = [self dataFilePath:[NSString stringWithFormat:@"%@_aggregate.plist", gameUniqueName]];
  [self removeFileAtFilePath:filePath];
}

+ (void) resetOperationQueue {
  [self removeFileAtFilePath:[self dataFilePath:kOperationQueueFilename]];
  [self removeFileAtFilePath:[self dataFilePath:kOperationsMarkedForRemovalFilename]];  
}

+ (void) loginTestUser {
  TPSessionService *session = [TPSessionService sharedInstance];
  
  NSDictionary *fakeUserDict = @{kTPDataResponseKey:
                                   @{@"user": @{kUniqueId: @"a2b2c3d4e5",
                                                kGuest: @(NO),
                                                kPrimaryAccount: @"tidepool",
                                                kAccountId: @"ios_test_user@example.com",
                                                kEmail: @"ios_test_user@example.com"
                                                },
                                     @"token": @{kOAuthResponseAccessToken: @"LongLivedTestUserToken",
                                                 kOAuthResponseExpiresIn: @(1200.00),
                                                 kOAuthResponseRefreshToken: @"LongLivedTestUserToken"
                                                 }
                                     }
                                 };
  
  if ([session respondsToSelector:@selector(initializeUserFromServerResponse:withError:) ]) {
    objc_msgSend(session, @selector(initializeUserFromServerResponse:withError:), fakeUserDict, nil);
  }
}

+ (void) loginTestUserWithExpiredAccessTokenInSeconds:(double) seconds {
  TPSessionService *session = [TPSessionService sharedInstance];
  
  NSDictionary *fakeUserDict = @{kTPDataResponseKey:
                                   @{@"user": @{kUniqueId: @"f1g2h3i4j6",
                                                kGuest: @(NO),
                                                kPrimaryAccount: @"tidepool",
                                                kAccountId: @"ios_test_user_expired@example.com",
                                                kEmail: @"ios_test_user_expired@example.com"
                                                },
                                     @"token": @{kOAuthResponseAccessToken: @"ExpiredAccessTokenTestUser",
                                                 kOAuthResponseExpiresIn: @(seconds),
                                                 kOAuthResponseRefreshToken: @"ExpiredAccessTokenTestUser"
                                                 }
                                     }
                                 };

  if ([session respondsToSelector:@selector(initializeUserFromServerResponse:withError:) ]) {
    objc_msgSend(session, @selector(initializeUserFromServerResponse:withError:), fakeUserDict, nil);
  }
}

+ (BOOL) folderExistsWithName:(NSString *) folderName {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *folderPath = [documentsPath stringByAppendingPathComponent:folderName];
  return [fileManager fileExistsAtPath:folderPath];
}

+ (void) cleanupUserFolders {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSArray *contents = [fileManager contentsOfDirectoryAtPath:rootPath error:nil];
  
  [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *folderName = (NSString *) obj;
    BOOL isDirectory = NO;
    NSString *folderPath = [rootPath stringByAppendingPathComponent:folderName];
    if ([fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory]) {
      if (isDirectory) {
        [fileManager removeItemAtPath:folderPath error:nil];
      }
    }
  }];
}

@end
