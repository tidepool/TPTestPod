//
//  TPGameAggregateResult.m
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import "TPGameAggregateResult.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "NSDate+TPDateCalculations.h"
#import "NSFileManager+TPFileUtils.h"

#import <Mantle/MTLJSONAdapter.h>

static NSString * const kGameResultId = @"id";
static NSString * const kGameUniqueName = @"game_unique_name";
static NSString * const kUserUniqueId = @"user_unique_id";
static NSString * const kRecentGames = @"recent_games";
static NSString * const kHighScore = @"high_score";
static NSString * const kHighestLevel = @"highest_level";
static NSString * const kExtraResultData = @"extra_result_data";
static NSString * const kMaxNumberOfTimesPlayedInOneDay = @"max_count_in_day";
static NSString * const kMaxNumberOfTimesPlayedInOneWeek = @"max_count_in_week";
static NSString * const kNumberOfTimesPlayedToday = @"times_played_today";
static NSString * const kNumberOfTimesPlayedThisWeek = @"times_played_this_week";
static NSString * const kNumberOfTimesPlayedTotal = @"times_played_total";
static NSString * const kLastPlayedAt = @"last_played_at";
static NSString * const kUpdatedAt = @"updated_at";

static NSString * const kGameAggregateFilename = @"game_aggregate";
@interface TPGameAggregateResult ()
@end

@implementation TPGameAggregateResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"resultId": kGameResultId,
           @"gameUniqueName": kGameUniqueName,
           @"userUniqueId": kUserUniqueId,
           @"recentGames": kRecentGames,
           @"highScore": kHighScore,
           @"highestLevel": kHighestLevel,
           @"extraResultData": kExtraResultData,
           @"maxNumberOfTimesPlayedInOneDay": kMaxNumberOfTimesPlayedInOneDay,
           @"maxNumberOfTimesPlayedInOneWeek": kMaxNumberOfTimesPlayedInOneWeek,
           @"numberOfTimesPlayedToday": kNumberOfTimesPlayedToday,
           @"numberOfTimesPlayedThisWeek": kNumberOfTimesPlayedThisWeek,
           @"numberOfTimesPlayedTotal": kNumberOfTimesPlayedTotal,
           @"lastPlayedAt": kLastPlayedAt,
           @"updatedAt": kUpdatedAt
           };
}

+ (NSValueTransformer *) lastPlayedAtJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [[TPSettings dateFormatter] dateFromString:str];
  } reverseBlock:^(NSDate *date) {
    return [[TPSettings dateFormatter] stringFromDate:date];
  }];
}

+ (NSValueTransformer *) updatedAtJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [[TPSettings dateFormatter] dateFromString:str];
  } reverseBlock:^(NSDate *date) {
    return [[TPSettings dateFormatter] stringFromDate:date];
  }];
}

+ (NSString *) filePathForGameUniqueName:(NSString *) gameUniqueName forUserId:(NSString *) userId {
  NSString *filename = [NSString stringWithFormat:@"%@-%@.plist", kGameAggregateFilename, gameUniqueName];
  NSString *filePath = [TPSettings filePathForFilename:filename folderName:userId];
  return filePath;
}

+ (void) aggregateResultForGameName:(NSString *) gameUniqueName
                            success:(void (^)(TPGameAggregateResult *gameAggregateResult))success
                            failure:(void (^)(NSError *error))failure {
  TPGameAggregateResult *result = [TPGameAggregateResult gameAggregateResultForGameUniqueName:gameUniqueName];
  success(result);
}

+ (instancetype) gameAggregateResultForGameUniqueName:(NSString *) gameUniqueName {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"Session user should not be nil.");
    return nil;
  }
  
  NSString *filePath = [self filePathForGameUniqueName:gameUniqueName forUserId:session.user.userId];
  TPGameAggregateResult *result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  
  if (result == nil) {
    // Nothing saved yet, initialize
    result = [[TPGameAggregateResult alloc] initWithGameUniqueName:gameUniqueName
                                                      userUniqueId:session.user.userId];
    [result saveWithErrorDescription:nil queueForUpdate:NO];
  }
  
  return result;
}

+ (NSArray *) gameAggregateResultsFromServerResponse:(NSArray *) serverResponse {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"User is nil, which is unexpected.");
    return nil;
  }
  
  NSMutableArray *aggregateResults = [NSMutableArray array];
  
  [serverResponse enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *resultDict = (NSDictionary *) obj;
    TPGameAggregateResult *result = [MTLJSONAdapter modelOfClass:TPGameAggregateResult.class fromJSONDictionary:resultDict error:nil];
    NSString *filePath = [self filePathForGameUniqueName:result.gameUniqueName
                                               forUserId:session.user.userId];
    
    TPGameAggregateResult *latest = (TPGameAggregateResult *) [self latestInSession:session persistedFilePath:filePath afterCompareWith:result];
    [aggregateResults addObject:latest];
  }];
  return aggregateResults;
}

+ (NSArray *) gameAggregateResultsFromLocalCopy {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"User is nil, which is unexpected.");
    return nil;
  }
  
  NSMutableArray *aggregateResults = [NSMutableArray array];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager enumerateFilesInFolder:session.user.userId filterByFilename:kGameAggregateFilename usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *filePath = (NSString *) obj;
    TPGameAggregateResult *result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    [aggregateResults addObject:result];
  }];
  
  return aggregateResults;
}

- (instancetype) initWithGameUniqueName:(NSString *) gameUniqueName
                           userUniqueId:(NSString *) userUniqueId {
  self = [super init];
  if (self) {
    _resultId = -1;
    _gameUniqueName = [gameUniqueName copy];
    _highScore = 0.0;
    _highestLevel = 0;
    _userUniqueId = [userUniqueId copy];
  }
  return self;
}

- (void) updateAggregateResultWithGameResult:(TPGameResult *) result {
  [self updateStatsForGameResult:result];
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
  TPGameAggregateResult *result = [MTLJSONAdapter modelOfClass:TPGameAggregateResult.class fromJSONDictionary:resultsResponse error:&error];
  
  return result;
}

- (BOOL) isFirstTimeSave {
  return (self.resultId == -1);
}

- (NSString *) localSaveFilePath {
  return [TPGameAggregateResult filePathForGameUniqueName:self.gameUniqueName forUserId:self.userUniqueId];
}

- (NSString *) saveToUrlInSession:(TPSessionService *) session {
  NSString *url = [kTPAggregateGameResultsUrlRoot stringByReplacingOccurrencesOfString:@"GAMEUNIQUENAME" withString:self.gameUniqueName];
  return [NSString stringWithFormat:@"%@%@", [session gameServiceBaseURL], url];
}

- (NSString *) updateUrlInSession:(TPSessionService *) session {
  NSString *url = [kTPAggregateGameResultsUrlRoot stringByReplacingOccurrencesOfString:@"GAMEUNIQUENAME" withString:self.gameUniqueName];

  return [NSString stringWithFormat:@"%@%@/%ld", [session gameServiceBaseURL], url, (long)self.resultId];
}


#pragma mark - Stat calculations

- (void) updateStatsForGameResult:(TPGameResult *) gameResult {
  [self updateHighScoreFromScore:gameResult.conanicalScore];
  [self updateHighestLevelFromLevelCompleted:gameResult.levelCompleted];
  [self updateDailyStatsForDate:gameResult.playedAt];
}

- (void) updateHighScoreFromScore:(double) score {
  if (score > self.highScore) {
    self.highScore = score;
  }
}

- (void) updateHighestLevelFromLevelCompleted:(NSInteger) levelCompleted {
  if (levelCompleted > self.highestLevel) {
    self.highestLevel = levelCompleted;
  }
}

@end
