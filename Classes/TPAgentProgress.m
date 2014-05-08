//
//  TPAgentProgress.m
//  Pods
//
//  Created by Kerem Karatal on 4/10/14.
//
//

#import "TPAgentProgress.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "TPMissionList.h"
#import "TPMission.h"
#import "TPGame.h"
#import "TPMissionAggregateResult.h"
#import "TPGameAggregateResult.h"
#import "TPBadgeDescription.h"

#import <ReactiveCocoa/RACEXTScope.h>

static NSString * const kAgentProgressId = @"id";
static NSString * const kLastMissionPlayed = @"last_mission_played";
static NSString * const kBadges = @"badges_earned";
static NSString * const kCognitiveScores = @"cognitive_scores";
static NSString * const kCognitiveMaxValues = @"cognitive_max_values";
static NSString * const kUserUniqueId = @"user_unique_id";
static NSString * const kUpdatedAt = @"updated_at";

static NSString * const kGameAggregateResults = @"game_aggregate_results";
static NSString * const kMissionAggregateResults = @"mission_aggregate_results";

static NSString * const kUniqueName = @"unique_name";
static NSString * const kNumberOfTimesEarned = @"number_of_times_earned";
static NSString * const kLastEarnedAt = @"last_earned_at";


@interface TPAgentProgress()
@property(nonatomic, strong) NSMutableDictionary *badges;  // Each badge -> (id, times, timeEarned)

- (void) setMissionAggregateResults:(NSArray *) results;
- (void) setGameAggregateResults:(NSArray *) results;
@end

@implementation TPAgentProgress {
  NSMutableArray *_missionAggregateResults;
  NSMutableArray *_gameAggregateResults;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"agentProgressId": kAgentProgressId,
           @"lastMissionPlayed": kLastMissionPlayed,
           @"badges": kBadges,
           @"userUniqueId": kUserUniqueId,
           @"cognitiveScores": kCognitiveScores,
           @"cognitiveMaxValues": kCognitiveMaxValues,
           @"updatedAt": kUpdatedAt
           };
}

+ (NSValueTransformer *) badgesJSONTransformer {
  return [MTLValueTransformer
          reversibleTransformerWithForwardBlock:^ id (id JSONDictionary) {
            if (JSONDictionary == nil) return nil;
            
            NSAssert([JSONDictionary isKindOfClass:NSDictionary.class], @"Expected a dictionary, got: %@", JSONDictionary);
            
            return [NSMutableDictionary dictionaryWithDictionary:JSONDictionary];
          }
          reverseBlock:^ id (id model) {
            if (model == nil) return nil;
            NSAssert([model isKindOfClass:NSDictionary.class], @"Expected a dictionary, got: %@", model);
            
            return model;
          }];

}

//+ (NSValueTransformer *) badgesJSONTransformer {
////  Class earnedBadgeClass = TPBadgeDescription.class;
////  NSParameterAssert([earnedBadgeClass isSubclassOfClass:MTLModel.class]);
//  return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:TPBadgeDescription.class];
//}


+ (NSValueTransformer *) updatedAtJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [[TPSettings dateFormatter] dateFromString:str];
  } reverseBlock:^(NSDate *date) {
    return [[TPSettings dateFormatter] stringFromDate:date];
  }];
}

+ (NSString *) filePathForUserId:(NSString *) userId {
  NSString *filePath = [TPSettings filePathForFilename:@"agent_progress.plist" folderName:userId];
  return filePath;
}

+ (instancetype) agentProgressFromLocalCopy {
  TPSessionService *session = [TPSessionService sharedInstance];
  assert(session.user != nil);
  
  NSString *filePath = [self filePathForUserId:session.user.userId];
  TPAgentProgress *agentProgress = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  
  if (agentProgress == nil) {
    // Nothing saved yet, initialize
    agentProgress = [[TPAgentProgress alloc] initWithUserUniqueId:session.user.userId];
    [agentProgress saveWithErrorDescription:nil queueForUpdate:NO];
  } else if (agentProgress.userUniqueId == nil) {
      agentProgress.userUniqueId = session.user.userId;
  }
  
  NSArray *missionAggregateResults = [TPMissionAggregateResult missionAggregateResultsFromLocalCopy];
  [agentProgress setMissionAggregateResults:missionAggregateResults];
  
  NSArray *gameAggregateResults = [TPGameAggregateResult gameAggregateResultsFromLocalCopy];
  [agentProgress setGameAggregateResults:gameAggregateResults];
  
  return agentProgress;
}

+ (void) agentProgressFromServerSuccess:(void (^)(TPAgentProgress *agentProgress))success
                                failure:(void (^)(NSError *error))failure {
  TPSessionService *session = [TPSessionService sharedInstance];
  assert(session.user != nil);
  
  [session GET:[self agentProgressURLRoot] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSDictionary *progressDict = [responseObject valueForKey:kTPDataResponseKey];
    TPAgentProgress *agentProgress = [MTLJSONAdapter modelOfClass:TPAgentProgress.class fromJSONDictionary:progressDict error:nil];
    
    NSArray *gameResultsArray = [progressDict objectForKey:kGameAggregateResults];
    if (gameResultsArray && [gameResultsArray count] > 0) {
      NSArray *gameAggregateResults = [TPGameAggregateResult gameAggregateResultsFromServerResponse:gameResultsArray];
      [agentProgress setGameAggregateResults:gameAggregateResults];
    }
    
    NSArray *missionResultsArray = [progressDict objectForKey:kMissionAggregateResults];
    if (missionResultsArray && [missionResultsArray count] > 0) {
      NSArray *missionAggregateResults = [TPMissionAggregateResult missionAggregateResultsFromServerResponse:missionResultsArray];
      [agentProgress setMissionAggregateResults:missionAggregateResults];
    }
    
    success(agentProgress);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (instancetype) init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype) initWithUserUniqueId:(NSString *) userUniqueId {
  self = [super init];
  if (self) {
    _userUniqueId = [userUniqueId copy];
    [self commonInit];
  }
  return self;
}

- (void) commonInit {
  NSDictionary *cognitiveScoreDefaults = @{kCognitiveScoreMemory: @(0.0),
                                           kCognitiveScoreAttention: @(0.0),
                                           kCognitiveScoreFlexibility: @(0.0),
                                           kCognitiveScoreProblemSolving: @(0.0),
                                           kCognitiveScoreSpeed: @(0.0)};
  
  NSDictionary *cognitiveMaxValueDefaults = @{kCognitiveScoreMemory: @(100.0),
                                              kCognitiveScoreAttention: @(100.0),
                                              kCognitiveScoreFlexibility: @(100.0),
                                              kCognitiveScoreProblemSolving: @(100.0),
                                              kCognitiveScoreSpeed: @(100.0)};
  
  _cognitiveScores = [NSDictionary dictionaryWithDictionary:cognitiveScoreDefaults];
  _cognitiveMaxValues = [NSDictionary dictionaryWithDictionary:cognitiveMaxValueDefaults];
  _missionAggregateResults = [NSMutableArray array];
  _gameAggregateResults = [NSMutableArray array];
  _badges = [NSMutableDictionary dictionary];
  _lastMissionPlayed = 0;
  _agentProgressId = -1;
}

- (void) setMissionAggregateResults:(NSArray *)results {
  _missionAggregateResults = [NSMutableArray arrayWithArray:results];
}

- (void) setGameAggregateResults:(NSArray *)results {
  _gameAggregateResults = [NSMutableArray arrayWithArray:results];
}

+ (NSString *) agentProgressURLRoot {
  return [NSString stringWithFormat:@"%@%@", [[TPSessionService sharedInstance] gameServiceBaseURL], kTPAgentProgressUrlRoot];
}

#pragma mark - Mission AggregateResults

- (NSArray *) missionAggregateResults {
  return _missionAggregateResults;
}

- (TPMissionAggregateResult *) missionAggregateResultForMission:(TPMission *) mission {
  __block TPMissionAggregateResult *foundResult = nil;
  [self.missionAggregateResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPMissionAggregateResult *result = (TPMissionAggregateResult *) obj;
    if ([result.missionUniqueName isEqualToString:mission.uniqueName]) {
      foundResult = result;
      *stop = YES;
    }
  }];
  if (foundResult == nil) {
    foundResult = [TPMissionAggregateResult missionAggregateResultForMissionUniqueName:mission.uniqueName];
    
    [_missionAggregateResults addObject:foundResult];
  }
  return foundResult;
}


#pragma mark - Game AggregateResults

- (NSArray *) gameAggregateResults {
  return _gameAggregateResults;
}

- (TPGameAggregateResult *) gameAggregateResultForGame:(TPGame *) game {
  __block TPGameAggregateResult *foundResult = nil;
  [self.gameAggregateResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPGameAggregateResult *result = (TPGameAggregateResult *) obj;
    if ([result.gameUniqueName isEqualToString:game.uniqueName]) {
      foundResult = result;
      *stop = YES;
    }
  }];
  if (foundResult == nil) {
    foundResult = [TPGameAggregateResult gameAggregateResultForGameUniqueName:game.uniqueName];
    
    [_gameAggregateResults addObject:foundResult];
  }
  return foundResult;
}

#pragma mark - Concrete TPLocalSerializable methods

- (void) willSaveToServerInSession:(TPSessionService *) session {
  if (self.userUniqueId == nil || [self.userUniqueId isEqualToString:@""]) {
    assert(session.user.userId != nil && ![session.user.userId isEqualToString:@""]);
    self.userUniqueId = session.user.userId;
  }
}

- (TPLocalSerializableModel *) didSaveToServerInSession:(TPSessionService *) session withResponse:(id) responseObject {
  NSDictionary *resultsResponse = [responseObject valueForKey:kTPDataResponseKey];
  NSError *error;
  TPAgentProgress *result = [MTLJSONAdapter modelOfClass:TPAgentProgress.class fromJSONDictionary:resultsResponse error:&error];
  
  return result;
}

- (BOOL) isFirstTimeSave {
  return (self.agentProgressId == -1);
}

- (NSString *) localSaveFilePath {
  TPSessionService *session = [TPSessionService sharedInstance];
  return [TPAgentProgress filePathForUserId:session.user.userId];
}

- (NSString *) saveToUrlInSession:(TPSessionService *) session {
  return [NSString stringWithFormat:@"%@%@", [session gameServiceBaseURL], kTPAgentProgressUrlRoot];
}

- (NSString *) updateUrlInSession:(TPSessionService *) session {
  return [NSString stringWithFormat:@"%@%@/%ld", [session gameServiceBaseURL], kTPAgentProgressUrlRoot, (long)self.agentProgressId];
}

#pragma mark - Badges

// TODO: This is the weirdest thing:
// For some reason TPBadgeDescription object does not work, no matter what I tried.
// It fails on:
// + (NSValueTransformer *)mtl_JSONDictionaryTransformerWithModelClass:(Class)modelClass {
//   NSParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);
//  ...
//
// So finally gave up and defined this as a NSDictionary!


//- (void) addNewBadge:(TPBadgeDescription *)newBadge {
//  NSParameterAssert(newBadge && newBadge.uniqueName != nil);
//  TPBadgeDescription *badge = [self.badges objectForKey:newBadge.uniqueName];
//  if (badge) {
//    badge.lastEarnedAt = [NSDate date];
//    badge.numberOfTimesEarned += 1;
//  } else {
//    newBadge.lastEarnedAt = [NSDate date];
//    newBadge.numberOfTimesEarned = 1;
//    [self.badges setObject:newBadge forKey:newBadge.uniqueName];
//  }
//}

- (void) addEarnedBadgeWithUniqueName:(NSString *)uniqueName {
  NSParameterAssert(uniqueName != nil && ![uniqueName isEqualToString:@""]);
  NSDateFormatter *dateFormatter = [TPSettings dateFormatter];
  NSMutableDictionary *badge = self.badges[uniqueName];
  if (badge) {
    badge[kLastEarnedAt] = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger numberOfTimesEarned = [badge[kNumberOfTimesEarned] intValue];
    numberOfTimesEarned += 1;
    badge[kNumberOfTimesEarned] = @(numberOfTimesEarned);
    self.badges[uniqueName] = badge;
  } else {
    NSMutableDictionary *newBadgeToAdd = [NSMutableDictionary dictionary];
    newBadgeToAdd[kUniqueName] = uniqueName;
    newBadgeToAdd[kLastEarnedAt] = [dateFormatter stringFromDate:[NSDate date]];
    newBadgeToAdd[kNumberOfTimesEarned] = @(1);
    self.badges[uniqueName] = newBadgeToAdd;
  }
}

- (TPBadgeDescription *) earnedBadgeWithUniqueName:(NSString *) uniqueName {
  NSMutableDictionary *badge = self.badges[uniqueName];
  TPBadgeDescription *badgeDesc = nil;
  if (badge != nil) {
    NSDateFormatter *dateFormatter = [TPSettings dateFormatter];
    NSDate *dateEarned = [dateFormatter dateFromString:badge[kLastEarnedAt]];
    badgeDesc = [[TPBadgeDescription alloc] initWithUniqueName:uniqueName
                                           numberOfTimesEarned:[badge[kNumberOfTimesEarned] intValue]
                                                  lastEarnedAt:dateEarned];
  }
  return badgeDesc;
}

- (NSArray *) allEarnedBadges {
  return [self.badges allValues];
}

#pragma mark - Cognitive Scores

-(void) addToAggregateCognitiveScoresObtained:(NSDictionary *)obtainedValues maxValues:(NSDictionary *)maxValues
{
  NSMutableDictionary *cognitiveScores = [self.cognitiveScores mutableCopy];
  NSMutableDictionary *cognitiveMaxValues = [self.cognitiveMaxValues mutableCopy];
  for (NSString *key in obtainedValues) {
    float value = [[obtainedValues valueForKey:key] floatValue];
    float prevValue = [[cognitiveScores valueForKey:key] floatValue];
    value += prevValue;
    [cognitiveScores setValue:[NSNumber numberWithFloat:value] forKey:key];
  }
  for (NSString *key in maxValues) {
    float value = [[maxValues valueForKey:key] floatValue];
    float prevValue = [[cognitiveMaxValues valueForKey:key] floatValue];
    value += prevValue;
    [cognitiveMaxValues setValue:[NSNumber numberWithFloat:value] forKey:key];
  }
  self.cognitiveScores = cognitiveScores;
  self.cognitiveMaxValues = cognitiveMaxValues;
}

@end
