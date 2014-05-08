//
//  TPMissionTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 3/5/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TPTestUtils.h"
#import <TPServices/TPMissionList.h>
#import <TPServices/TPMission.h>
#import <TPServices/TPStoryScreen.h>
#import <TPServices/TPMissionStage.h>
#import <TPServices/TPGameRequirement.h>

@interface TPMissionTests : XCTestCase

@end

@implementation TPMissionTests

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
  [TPTestUtils cleanupUserFolders];
}

#pragma mark - Unit Tests

- (void) testInitializingMissionWithJson2 {
  NSString *filePath = [[NSBundle bundleForClass: [TPMissionTests class]] pathForResource:@"sample_mission" ofType:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
  NSError *error;
  NSArray *missions = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
  
  TPMission *mission = [MTLJSONAdapter modelOfClass:TPMission.class fromJSONDictionary:[missions objectAtIndex:0] error:&error];
  
  expect(mission).notTo.beNil;
  
  TPMissionStage *stage = [mission.stages objectAtIndex:0];
  expect(stage).notTo.beNil;
  
  TPGameConfig *gameConfig = stage.gameConfig;
  expect(gameConfig).notTo.beNil;

  TPStory *headerStory = stage.headerStory;
  expect(headerStory).notTo.beNil;
  
  TPStory *footerStory = stage.footerStory;
  expect(footerStory).notTo.beNil;
  
  TPStoryScreen *storyScreen = (TPStoryScreen *)[headerStory.screens objectAtIndex:0];
  expect(storyScreen).notTo.beNil;
  
  NSArray *requirements = mission.requirements;
  
  expect(requirements).notTo.beNil;
  TPGameRequirement *requirement = (TPGameRequirement *) [requirements objectAtIndex:0];
  expect([requirement.gameUniqueName isEqualToString:@"Codebreaker"]).to.beTruthy;
  expect(requirement.playCount).to.beGreaterThan(0);
}

#pragma mark - Integration - Missions API

- (void) testRetrievingAllMissions {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];

  __block NSArray *allMissions = nil;
  __block NSString *errorDesc;
  
  TPMissionList *missionList = [[TPMissionList alloc] init];
  
  [missionList refreshMissionListSuccess:^(NSArray *missions) {
    allMissions = missions;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  
  expect([allMissions count]).will.equal(3);
}

- (void) testReadingMissionsFromServer {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block NSArray *allMissions = nil;
  __block BOOL waitingForResponse = YES;
  __block NSString *errorDesc;
  
//  TPMissionList *missionList = [[TPMissionList alloc] init];
//  [missionList readWithParams:nil success:^(MTLModel *model) {
//    allMissions = ((TPMissionList *) model).missions;
//    waitingForResponse = NO;
//  } failure:^(NSError *error) {
//    errorDesc = [error description];
//  }];
//  
  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                               beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
 
  expect([allMissions count]).will.equal(3);
}

@end
