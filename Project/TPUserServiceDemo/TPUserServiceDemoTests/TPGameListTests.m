//
//  TPGameListTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/23/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPSessionService.h>
#import <TPServices/TPGameList.h>
#import "TPTestUtils.h"

@interface TPGameListTests : XCTestCase

@end

@implementation TPGameListTests


- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  [TPTestUtils resetKeyChain];
  [TPTestUtils loginTestUser];
  
}

- (void) tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  [TPTestUtils resetKeyChain];
  [TPTestUtils cleanupUserFolders];
}

#pragma mark - Unit Tests

- (void) testLoadingGameList {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block NSArray *refreshedGames = nil;
  __block NSString *errorDesc;

  TPGameList *gameList = [[TPGameList alloc] init];
  expect(gameList.games).to.beNil;
  [gameList refreshGameListSuccess:^(NSArray *games) {
    refreshedGames = games;
  } failure:^(NSError *error) {
    
  }];
  
  expect([refreshedGames count]).will.equal(3);
  expect(gameList.games).willNot.beNil;
}


@end
