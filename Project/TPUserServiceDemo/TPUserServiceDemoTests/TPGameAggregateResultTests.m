//
//  TPGameAggregateResultTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/8/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPGameAggregateResult.h>
#import "TPTestUtils.h"
#import <TPServices/TPSettings.h>


static NSString * const kTestGameUniqueName = @"lockpicker";

@interface TPGameAggregateResultTests : XCTestCase
@end

@implementation TPGameAggregateResultTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  [TPTestUtils resetKeyChain];
  [TPTestUtils resetGameAggregateResultLocalDataForGame:kTestGameUniqueName];
  [TPTestUtils loginTestUser];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  [TPTestUtils resetKeyChain];
}

- (void) testLoadingFirstData {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block TPGameAggregateResult *result = nil;
  __block BOOL waitingForResponse = YES;
  [TPGameAggregateResult aggregateResultForGameName:kTestGameUniqueName success:^(TPGameAggregateResult *gameAggregateResult) {
    result = gameAggregateResult;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    
  }];
  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  expect(result).notTo.beNil;
  expect([result.gameUniqueName isEqualToString:kTestGameUniqueName]).to.beTruthy;
}

- (void) testPersistingToDisk {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block TPGameAggregateResult *result = nil;
  __block BOOL waitingForResponse = YES;
  [TPGameAggregateResult aggregateResultForGameName:kTestGameUniqueName success:^(TPGameAggregateResult *gameAggregateResult) {
    result = gameAggregateResult;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    
  }];
  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  NSError *error;
  result.highScore = 100.0f;
  [result saveWithErrorDescription:&error queueForUpdate:NO];
 
  waitingForResponse = YES;
  __block TPGameAggregateResult *otherResult = nil;
  [TPGameAggregateResult aggregateResultForGameName:kTestGameUniqueName success:^(TPGameAggregateResult *gameAggregateResult) {
    otherResult = gameAggregateResult;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    
  }];
  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  
  expect(otherResult.highScore).will.equal(100.0f);
}

- (void) testUpdateMaxNumberOfTimesPlayedInOneDay {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block TPGameAggregateResult *result = nil;
  __block BOOL waitingForResponse = YES;
  [TPGameAggregateResult aggregateResultForGameName:kTestGameUniqueName success:^(TPGameAggregateResult *gameAggregateResult) {
    result = gameAggregateResult;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    
  }];
  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }

  NSDateFormatter *dateFormatter = [TPSettings dateOnlyFormatter];
  NSDate *day1 = [dateFormatter dateFromString:@"2014-04-01"];
  NSDate *day2 = [dateFormatter dateFromString:@"2014-04-03"];
  NSDate *day3 = [dateFormatter dateFromString:@"2014-04-04"];
  [result updateMaxNumberOfTimesPlayedInOneDay:day2 whenLastPlayedAt:day1];
  expect(result.numberOfTimesPlayedToday).equal(1);
  expect(result.maxNumberOfTimesPlayedInOneDay).equal(1);
  
  [result updateMaxNumberOfTimesPlayedInOneDay:day2 whenLastPlayedAt:day2];
  expect(result.numberOfTimesPlayedToday).equal(2);
  expect(result.maxNumberOfTimesPlayedInOneDay).equal(2);

  [result updateMaxNumberOfTimesPlayedInOneDay:day3 whenLastPlayedAt:day2];
  expect(result.numberOfTimesPlayedToday).equal(1);
  expect(result.maxNumberOfTimesPlayedInOneDay).equal(2);

  [result updateMaxNumberOfTimesPlayedInOneDay:day3 whenLastPlayedAt:day3];
  [result updateMaxNumberOfTimesPlayedInOneDay:day3 whenLastPlayedAt:day3];
  expect(result.numberOfTimesPlayedToday).equal(3);
  expect(result.maxNumberOfTimesPlayedInOneDay).equal(3);
}

- (void) testUpdateMaxNumberOfTimesPlayedInOneWeek {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block TPGameAggregateResult *result = nil;
  __block BOOL waitingForResponse = YES;
  [TPGameAggregateResult aggregateResultForGameName:kTestGameUniqueName success:^(TPGameAggregateResult *gameAggregateResult) {
    result = gameAggregateResult;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    
  }];
  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  NSDateFormatter *dateFormatter = [TPSettings dateOnlyFormatter];
  NSDate *day1 = [dateFormatter dateFromString:@"2014-03-01"];
  NSDate *day2 = [dateFormatter dateFromString:@"2014-04-03"];
  NSDate *day3 = [dateFormatter dateFromString:@"2014-04-05"];
  NSDate *day4 = [dateFormatter dateFromString:@"2014-04-07"];
  [result updateMaxNumberOfTimesPlayedInOneWeek:day2 whenLastPlayedAt:day1];
  expect(result.numberOfTimesPlayedThisWeek).equal(1);
  expect(result.maxNumberOfTimesPlayedInOneWeek).equal(1);
  
  [result updateMaxNumberOfTimesPlayedInOneWeek:day2 whenLastPlayedAt:day2];
  expect(result.numberOfTimesPlayedThisWeek).equal(2);
  expect(result.maxNumberOfTimesPlayedInOneWeek).equal(2);
  
  [result updateMaxNumberOfTimesPlayedInOneWeek:day3 whenLastPlayedAt:day2];
  expect(result.numberOfTimesPlayedThisWeek).equal(3);
  expect(result.maxNumberOfTimesPlayedInOneWeek).equal(3);
  
  [result updateMaxNumberOfTimesPlayedInOneWeek:day4 whenLastPlayedAt:day3];
  [result updateMaxNumberOfTimesPlayedInOneWeek:day4 whenLastPlayedAt:day4];
  expect(result.numberOfTimesPlayedThisWeek).equal(2);
  expect(result.maxNumberOfTimesPlayedInOneWeek).equal(3);
  
}

@end
