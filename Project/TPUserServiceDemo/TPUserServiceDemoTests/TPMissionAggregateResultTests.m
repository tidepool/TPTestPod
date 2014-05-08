//
//  TPMissionAggregateResultTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/22/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPMissionAggregateResult.h>
#import "TPTestUtils.h"
#import <TPServices/TPSettings.h>


static NSString * const kTestGameUniqueName = @"lockpicker";

@interface TPMissionAggregateResultTests : XCTestCase
@end

@implementation TPMissionAggregateResultTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  [TPTestUtils resetKeyChain];
  [TPTestUtils loginTestUser];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  [TPTestUtils resetKeyChain];
}

#pragma mark - Integration Tests

- (void) testLoadingMissionAggregateResultForFirstTime {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block TPMissionAggregateResult *result;
  [TPMissionAggregateResult missionAggregateResultForMissionUniqueName:@"1" success:^(TPMissionAggregateResult *missionAggregateResult) {
    result = missionAggregateResult;
  } failure:^(NSError *error) {
    
  }];
  
  expect(result).will.notTo.beNil;
  expect([result.missionUniqueName isEqualToString:@"1"]).to.beTruthy;
}

- (void) testSavingResults {
  
}


@end
