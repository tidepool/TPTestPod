//
//  TPGameResultTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 3/7/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPGameResult.h>
#import "TPTestUtils.h"

@interface TPGameResultTests : XCTestCase

@end

@implementation TPGameResultTests

#pragma mark - Setup

- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
  [TPTestUtils resetKeyChain];
  [TPTestUtils loginTestUser];
}

- (void)tearDown {
  // Put teardown code here; it will be run once, after the last test case.
  [super tearDown];
  [TPTestUtils resetKeyChain];
}

#pragma mark - Unit Tests

- (void) testInitializingMissionWithJson {
  TPGameResult  *gameResult = [self fakeResult];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
  NSDate *expectedDate = [formatter dateFromString:@"2014-02-04T15:20:59.195-08:00"];
  
  expect(gameResult).notTo.beNil;
  expect(gameResult.resultId).to.equal(1);
  expect(gameResult.gameId).to.equal(2);
  expect(gameResult.gameUniqueName).to.equal(@"Memory");
  expect(gameResult.userUniqueId).to.equal(@"a2b2c3d4e5");
  expect(gameResult.playedAt).to.equal(expectedDate);
  expect(gameResult.playedAs).to.equal(TPPlayedAsTraining);
  expect(gameResult.conanicalScore).to.equal(1234);
}

#pragma mark - Integration - Results API

//- (void) testRetrievingGameResults {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  __block NSArray *gameResults = nil;
//  __block TPGameResult *sampleResult = nil;
//  __block NSString *errorDesc;
//  
//  [TPGameResult findResultsByGameName:@"Shooter" success:^(NSArray *results) {
//    gameResults = results;
//    sampleResult = [gameResults objectAtIndex:0];
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  expect([gameResults count]).will.equal(10);
//  expect(sampleResult.playedAt).will.notTo.beNil;
//}
//
//- (void) testCreatingGameResult {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  __block TPGameResult *savedResult = nil;
//  __block NSString *errorDesc;
//
//  TPGameResult *newResult = [[TPGameResult alloc] init];
//  expect(newResult.resultId).equal(-1);
//  newResult.conanicalScore = 140;
//  newResult.gameUniqueName = @"LockPicker";
//  newResult.playedAt = [NSDate dateWithTimeIntervalSinceNow:0];
//  
//  [newResult saveResultSuccess:^(TPGameResult *result) {
//    savedResult = result;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//
//  expect(savedResult.playedAt).will.notTo.beNil;
//  expect(savedResult.gameUniqueName).will.equal(@"LockPicker");
//  expect(savedResult.conanicalScore).will.equal(140);
//  expect(savedResult.resultId).willNot.equal(-1);
//}
//
//- (void) testUpdatingGameResult {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  __block TPGameResult *savedResult = nil;
//  __block NSString *errorDesc;
//
//  TPGameResult *existingResult = [self fakeResult];
//  
//  [existingResult saveResultSuccess:^(TPGameResult *result) {
//    savedResult = result;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  
//  expect(savedResult.playedAt).will.notTo.beNil;
//  expect(savedResult.gameUniqueName).will.equal(@"Memory");
//  expect(savedResult.conanicalScore).will.equal(1234);
//}
//
//- (void) testArbitrarilyAssigningGameUniqueName {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  __block TPGameResult *savedResult = nil;
//  __block NSString *errorDesc;
//  
//  TPGameResult *existingResult = [self fakeResult];
//  existingResult.gameUniqueName = @"ArbitraryName";
//  
//  [existingResult saveResultSuccess:^(TPGameResult *result) {
//    savedResult = result;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  
//  expect(savedResult.gameUniqueName).will.equal(@"Memory");
//}
//
//- (void) testSendingNonExistingGame {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  __block TPGameResult *savedResult = nil;
//  __block NSString *errorMessage = nil;
//  __block NSInteger errorCode = 0;
//  
//  TPGameResult *newResult = [[TPGameResult alloc] init];
//  expect(newResult.resultId).equal(-1);
//  newResult.conanicalScore = 140;
//  newResult.gameUniqueName = @"NonExistingGame";
//  newResult.playedAt = [NSDate dateWithTimeIntervalSinceNow:0];
//  
//  [newResult saveResultSuccess:^(TPGameResult *result) {
//    savedResult = result;
//  } failure:^(NSError *error) {
//    errorMessage = [[error userInfo] objectForKey:kTPUserFriendlyErrorMessage];
//    errorCode = [[[error userInfo] objectForKey:kTPFailureCode] integerValue];
//  }];
//  
//  expect(errorMessage).will.equal(@"No game with NonExistingGame");
//  expect(errorCode).will.equal(1001);
//}

- (TPGameResult *) fakeResult {
  NSDictionary *input = @{
                          @"id": @(1),
                          @"game_id": @(2),
                          @"game_unique_name": @"Memory",
                          @"user_unique_id": @"a2b2c3d4e5",
                          @"played_at": @"2014-02-04T15:20:59.195-08:00",
                          @"played_as": @"training",
                          @"conanical_score": @(1234)
                          };
  
  NSError *error;
  TPGameResult  *gameResult = [MTLJSONAdapter modelOfClass:TPGameResult.class fromJSONDictionary:input error:&error];
  return gameResult;
}


@end
