//
//  TPTestUtils.h
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 3/6/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EXP_SHORTHAND YES
#import "Expecta.h"
#import "OCMock.h"
#import <SSKeychain/SSKeychain.h>

#define EXPECTA_TEST_TIMEOUT 200
#define waitUntilFalse(waitingForResponse) while(waitingForResponse) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; }


@interface TPTestUtils : NSObject

+ (void) mockSessionReachabilityWithReachabilityStatus:(BOOL) isReachable ;
+ (void) resetKeyChain;
+ (void) resetOperationQueue;
+ (void) loginTestUser;
+ (void) loginTestUserWithExpiredAccessTokenInSeconds:(double) seconds;
+ (void) resetGameAggregateResultLocalDataForGame:(NSString *) gameUniqueName;
+ (BOOL) folderExistsWithName:(NSString *) folderName;
+ (void) cleanupUserFolders;
@end
