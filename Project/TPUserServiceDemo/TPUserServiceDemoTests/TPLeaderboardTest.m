//
//  TPLeaderboardTest.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/11/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPSessionService.h>
#import <TPServices/TPLeader.h>
#import "TPTestUtils.h"

@interface TPLeaderboardTest : XCTestCase

@end

@implementation TPLeaderboardTest

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

- (void) testGettingLeaders {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block NSArray *foundLeaders = nil;
  __block TPLeader *foundLeader = nil;
  __block TPPageInfo returnedPageInfo;
  __block NSString *errorDesc;
  TPPageInfo pageInfo = { 0, 10, 0, 0, 0 };
  
  [TPLeader findByLeaderboardId:@"Shootout" pageInfo:pageInfo success:^(NSArray *leaders, TPPageInfo pageInfo) {
    foundLeaders = leaders;
    foundLeader = [leaders objectAtIndex:0];
    returnedPageInfo = pageInfo;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  
  expect([foundLeaders count]).will.equal(10);
  expect(returnedPageInfo.total).will.equal(10);
  expect(foundLeader.name).will.notTo.beNil;
  expect(foundLeader.profilePhotoURL).will.notTo.beNil;
  expect(foundLeader.userId).will.notTo.beNil;
}
@end
