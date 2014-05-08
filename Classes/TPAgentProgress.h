//
//  TPAgentProgress.h
//  Pods
//
//  Created by Kerem Karatal on 4/10/14.
//
//

#import "TPLocalSerializableModel.h"

static NSString * const kCognitiveScoreAttention = @"attention";
static NSString * const kCognitiveScoreMemory = @"memory";
static NSString * const kCognitiveScoreSpeed = @"speed";
static NSString * const kCognitiveScoreFlexibility = @"flexibility";
static NSString * const kCognitiveScoreProblemSolving = @"problem_solving";

@class TPMission;
@class TPGame;
@class TPMissionAggregateResult;
@class TPGameAggregateResult;
@class TPBadgeDescription;

@interface TPAgentProgress : TPLocalSerializableModel
@property(nonatomic, assign) NSInteger agentProgressId;
@property(nonatomic, copy) NSString *userUniqueId;
@property(nonatomic, assign) NSInteger lastMissionPlayed;
@property(nonatomic, strong) NSDictionary *cognitiveScores;
@property(nonatomic, strong) NSDictionary *cognitiveMaxValues;

+ (instancetype) agentProgressFromLocalCopy;
+ (void) agentProgressFromServerSuccess:(void (^)(TPAgentProgress *agentProgress))success
                                failure:(void (^)(NSError *error))failure;

- (NSArray *) missionAggregateResults;
- (NSArray *) gameAggregateResults;

- (TPMissionAggregateResult *) missionAggregateResultForMission:(TPMission *) mission;
- (TPGameAggregateResult *) gameAggregateResultForGame:(TPGame *) game;

- (void) addToAggregateCognitiveScoresObtained:(NSDictionary *)obtainedValues maxValues:(NSDictionary *)maxValues;

- (void) addEarnedBadgeWithUniqueName:(NSString *)uniqueName;
- (TPBadgeDescription *) earnedBadgeWithUniqueName:(NSString *) uniqueName;
- (NSArray *) allEarnedBadges;

@end
