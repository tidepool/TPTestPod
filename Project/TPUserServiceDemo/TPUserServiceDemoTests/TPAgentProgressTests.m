//
//  TPAgentProgressTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 4/16/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPSessionService.h>
#import <TPServices/TPAgentProgress.h>
#import <TPServices/TPMissionAggregateResult.h>
#import <TPServices/TPMissionResult.h>
#import <TPServices/TPBadgeDescription.h>
#import "TPTestUtils.h"

static NSString * const kLastMissionPlayed = @"last_mission_played";
static NSString * const kBadgesEarned = @"badges_earned";
static NSString * const kCognitiveScores = @"cognitive_scores";
static NSString * const kCognitiveMaxValues = @"cognitive_max_values";
static NSString * const kUserUniqueId = @"user_unique_id";


static NSString * const kUniqueName = @"unique_name";
static NSString * const kNumberOfTimesEarned = @"number_of_times_earned";
static NSString * const kLastEarnedAt = @"last_earned_at";

@interface TPAgentProgressTests : XCTestCase

@end

@implementation TPAgentProgressTests

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

- (NSDictionary *) mockAgentProgressDictionary {
  NSDictionary *cognitiveScores = @{kCognitiveScoreMemory: @(100.0),
                                    kCognitiveScoreAttention: @(55.0),
                                    kCognitiveScoreFlexibility: @(75.0),
                                    kCognitiveScoreProblemSolving: @(90.0),
                                    kCognitiveScoreSpeed: @(10.0)};
  
  NSDictionary *agentProgressDict = @{kLastMissionPlayed: @(2),
                                        kCognitiveScores: cognitiveScores,
                                     kCognitiveMaxValues: cognitiveScores};
  
  return agentProgressDict;
}

- (void) setupMockLocalData {
  NSDictionary *input = [self mockAgentProgressDictionary];
  NSError *error;
  TPAgentProgress *agentProgress = [MTLJSONAdapter modelOfClass:TPAgentProgress.class fromJSONDictionary:input error:&error];

  [agentProgress saveWithErrorDescription:nil queueForUpdate:NO];
}

#pragma mark - Unit Tests

- (void) testSerializingAgentProgress {
  NSDictionary *input = [self mockAgentProgressDictionary];
  
  NSError *error;
  TPAgentProgress *agentProgress = [MTLJSONAdapter modelOfClass:TPAgentProgress.class fromJSONDictionary:input error:&error];

  expect(agentProgress).notTo.beNil;
}

- (void) testBadgeDescription {
  NSDictionary *input = @{kUniqueName: @"12345",
                          kNumberOfTimesEarned: @(5),
                          kLastEarnedAt: @"2014-02-04T15:20:59.195-08:00"
                          };
  NSError *error;
  TPBadgeDescription *badge = [MTLJSONAdapter modelOfClass:TPBadgeDescription.class fromJSONDictionary:input error:&error];
  
  expect(badge).notTo.beNil;
}

- (void) testAddingABadge {
  
  TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
  
  [agentProgress addEarnedBadgeWithUniqueName:@"Foo"];
  
  TPBadgeDescription *badgeDesc = [agentProgress earnedBadgeWithUniqueName:@"Foo"];
  expect(badgeDesc.numberOfTimesEarned).to.equal(1);
  expect(badgeDesc.lastEarnedAt).notTo.beNil;

  [agentProgress addEarnedBadgeWithUniqueName:@"Foo"];
  badgeDesc = [agentProgress earnedBadgeWithUniqueName:@"Foo"];
  expect(badgeDesc.numberOfTimesEarned).to.equal(2);
  
  [agentProgress addEarnedBadgeWithUniqueName:@"Bar"];
  badgeDesc = [agentProgress earnedBadgeWithUniqueName:@"Bar"];
  expect(badgeDesc.numberOfTimesEarned).to.equal(1);
}

#pragma mark - Integration Tests

- (void) testReadingAgentProgressFromServer {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];

  __block TPAgentProgress *foundProgress = nil;
  __block NSString *errorDesc;
  __block BOOL waitingForResponse = YES;

  [TPAgentProgress agentProgressFromServerSuccess:^(TPAgentProgress *agentProgress) {
    foundProgress = agentProgress;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    errorDesc = [error description];
    waitingForResponse = NO;
  }];
  waitUntilFalse(waitingForResponse);
  expect(foundProgress).will.notTo.beNil;
  expect([[foundProgress missionAggregateResults] count]).will.equal(5);
  expect([[foundProgress gameAggregateResults] count]).will.equal(4);
}

- (void) testLoadingAgentProgressFromLocalForFirstTime {
  TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
  
  expect(agentProgress).notTo.beNil;
  expect([[agentProgress missionAggregateResults] count]).to.equal(0);
  expect([[agentProgress gameAggregateResults] count]).to.equal(0);
  expect(agentProgress.userUniqueId).notTo.beNil;
  expect(agentProgress.lastMissionPlayed).to.equal(0);
}

- (void) testLoadingAgentProgressFromLocalForNextTimes {
  [self setupMockLocalData];
  TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
  
  expect(agentProgress).notTo.beNil;
  expect(agentProgress.userUniqueId).notTo.beNil;
  expect(agentProgress.lastMissionPlayed).to.equal(2);
}

- (void) testWritingBackAgentProgress {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  [self setupMockLocalData];
  TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
  agentProgress.lastMissionPlayed = 2;
////  NSDictionary *newBadge = @{@"unique_name": @"foo"};
//  TPBadgeDescription *newBadge = [[TPBadgeDescription alloc] initWithUniqueName:@"FooBadge"];
//  newBadge.numberOfTimesEarned = 10;
  
  [agentProgress addEarnedBadgeWithUniqueName:@"Foo"];
  
  __block TPAgentProgress *savedProgress;
  __block BOOL waitingForResponse = YES;
  [agentProgress saveSuccess:^(MTLModel *model) {
    savedProgress = (TPAgentProgress *) model;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    waitingForResponse = NO;
  }];

  while(waitingForResponse) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }

  expect(savedProgress.lastMissionPlayed).will.equal(2);
  expect(savedProgress.cognitiveScores[kCognitiveScoreAttention]).will.equal(55);
  
  TPBadgeDescription *badgeDesc = [savedProgress earnedBadgeWithUniqueName:@"Foo"];
  expect(badgeDesc).will.notTo.beNil;
  
  [savedProgress addEarnedBadgeWithUniqueName:@"Bar"];
  badgeDesc = [savedProgress earnedBadgeWithUniqueName:@"Bar"];
  expect(badgeDesc).will.notTo.beNil;
}


//
//- (void) testGettingAggregateMissionResults {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  TPAgentProgress *agentProgress = [self loadAgentProgressSynchronously];
//  
//  __block NSArray *results;
//  [agentProgress refreshMissionAggregateResultsSuccess:^(NSArray *missionAggregateResults) {
//    results = missionAggregateResults;
//  } failure:^(NSError *error) {
//    
//  }];
//  
//  expect([results count]).will.equal(3);
//  expect([agentProgress missionAggregateResults]).willNot.beNil;
//}
//
//- (void) testOperatingOnAggregateMissionResults {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  TPAgentProgress *agentProgress = [self loadAgentProgressSynchronously];
//  
//  __block NSArray *results;
//  __block BOOL waitingForResponse = YES;
//  [agentProgress refreshMissionAggregateResultsSuccess:^(NSArray *missionAggregateResults) {
//    results = missionAggregateResults;
//    waitingForResponse = NO;
//  } failure:^(NSError *error) {
//    
//  }];
//
//  waitUntilFalse(waitingForResponse);
//  
//  TPMissionAggregateResult *aggregateResult = [results objectAtIndex:0];
//  TPMissionResult *result = [TPMissionResult missionResultWithMissionName:aggregateResult.missionUniqueName withBlock:^(TPMissionResult *missionResult) {
//    missionResult.numberOfStars = 3;
//    missionResult.playDuration = 1.2f;
//  }];
//  [aggregateResult updateAggregateResultWithMissionResult:result];
//  [aggregateResult saveWithErrorDescription:nil queueForUpdate:NO];
//  
//}
//
//- (void) testAddingEarnedBadges {
//  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
//  
//  TPAgentProgress *agentProgress = [self loadAgentProgressSynchronously];
//  
//  TPEarnedBadge *earnedBadge = [[TPEarnedBadge alloc] initWithUniqueName:@"badge123"];
//  
//  [agentProgress addNewBadge:earnedBadge];
//  expect([agentProgress.badgesEarned count]).to.equal(1);
//  
//  // Adding the same badge does not increment the count of badges
//  [agentProgress addNewBadge:earnedBadge];
//  expect([agentProgress.badgesEarned count]).to.equal(1);
//  TPEarnedBadge *badge = [agentProgress.badgesEarned objectAtIndex:0];
//  expect([badge.uniqueName isEqualToString:@"badge123"]).to.beTruthy;
//  expect(badge.numberOfTimesEarned).to.equal(2);
//  
//  // Now add another badge
//  TPEarnedBadge *earnedBadge2 = [[TPEarnedBadge alloc] initWithUniqueName:@"badge345"];
//  [agentProgress addNewBadge:earnedBadge2];
//  expect([agentProgress.badgesEarned count]).to.equal(2);
//}

@end
