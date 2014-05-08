//
//  TPBackgroundNetworkOperationQueueTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/9/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TPTestUtils.h"
#import <TPServices/TPSessionService.h>
#import <TPServices/TPCommon.h>
#import <TPServices/TPSettings.h>
#import <TPServices/TPBackgroundNetworkOperationQueue.h>
#import <TPServices/TPGameAggregateResult.h>

@interface TPBackgroundNetworkOperationQueueTests : XCTestCase

@end

@implementation TPBackgroundNetworkOperationQueueTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  [TPTestUtils resetOperationQueue];
  [TPTestUtils resetGameAggregateResultLocalDataForGame:(NSString *)kTPGameCodeBreaker];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void) testLoadingInitialOperationQueue {
  TPBackgroundNetworkOperationQueue *queue = [TPBackgroundNetworkOperationQueue sharedInstance];
  
  expect(queue).notTo.beNil;
}

//- (void) testArchivingOperations {
//  TPBackgroundNetworkOperationQueue *queue = [TPBackgroundNetworkOperationQueue sharedInstance];
//  
//  NSError *error;
//  TPGameAggregateResult *result = [TPGameAggregateResult aggregateResultForGameName:kTPGameCodeBreaker errorDescription:&error];
//  TPBackgroundNetworkOperation *operation = [[TPBackgroundNetworkOperation alloc] initWithModel:result
//                                                                                  operationType:TPSaveOperation
//                                                                             duplicationAllowed:NO];
//  
//  [queue addOperation:operation tryFlushing:NO];
//  expect([queue operationsCount]).to.equal(1);
//}
//
//- (void) testNotBeingAbleToAddDuplicateOperations {
//  TPBackgroundNetworkOperationQueue *queue = [TPBackgroundNetworkOperationQueue sharedInstance];
//  
//  NSError *error;
//  TPGameAggregateResult *result = [TPGameAggregateResult aggregateResultForGameName:kTPGameCodeBreaker errorDescription:&error];
//  TPBackgroundNetworkOperation *operation = [[TPBackgroundNetworkOperation alloc] initWithModel:result
//                                                                                  operationType:TPSaveOperation
//                                                                             duplicationAllowed:NO];
//  
//  [queue addOperation:operation tryFlushing:NO];
//  [queue addOperation:operation tryFlushing:NO];
//  expect([queue operationsCount]).to.equal(1);
//}
//
//- (void) testFlushingOperationQueue {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  [TPTestUtils loginTestUser];
//  
//  TPBackgroundNetworkOperationQueue *queue = [TPBackgroundNetworkOperationQueue sharedInstance];
//  
//  NSError *error;
//  TPGameAggregateResult *result = [TPGameAggregateResult aggregateResultForGameName:kTPGameCodeBreaker errorDescription:&error];
//  expect(result.resultId).to.equal(-1);
//  TPBackgroundNetworkOperation *operation = [[TPBackgroundNetworkOperation alloc] initWithModel:result
//                                                                                  operationType:TPSaveOperation
//                                                                             duplicationAllowed:NO];
//  
//  [queue addOperation:operation tryFlushing:YES];
//
////  while(true) {
////    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
////                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
////  }
//  
//  expect([TPGameAggregateResult aggregateResultForGameName:kTPGameCodeBreaker errorDescription:nil].resultId).willNot.equal(-1);
//}
//
@end
