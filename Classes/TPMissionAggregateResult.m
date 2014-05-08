//
//  TPMissionAggregateResult.m
//  Pods
//
//  Created by Kerem Karatal on 4/18/14.
//
//

#import "TPMissionAggregateResult.h"
#import "TPSettings.h"
#import "NSDate+TPDateCalculations.h"
#import "TPCommon.h"
#import "NSFileManager+TPFileUtils.h"

static NSString * const kResultId = @"id";
static NSString * const kMissionUniqueName = @"mission_unique_name";
static NSString * const kUserUniqueId = @"user_unique_id";
static NSString * const kBestTimingInSeconds = @"best_timing_in_seconds";
static NSString * const kHighestStarsCount = @"highest_stars_count";
static NSString * const kExtraResultData = @"extra_result_data";
static NSString * const kMaxNumberOfTimesPlayedInOneDay = @"max_count_in_day";
static NSString * const kMaxNumberOfTimesPlayedInOneWeek = @"max_count_in_week";
static NSString * const kNumberOfTimesPlayedToday = @"times_played_today";
static NSString * const kNumberOfTimesPlayedThisWeek = @"times_played_this_week";
static NSString * const kNumberOfTimesPlayedTotal = @"times_played_total";
static NSString * const kLastPlayedAt = @"last_played_at";
static NSString * const kUpdatedAt = @"updated_at";

static NSString * const kMissionAggregateFilename = @"mission_aggregate";


@implementation TPMissionAggregateResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"resultId": kResultId,
           @"missionUniqueName": kMissionUniqueName,
           @"userUniqueId": kUserUniqueId,
           @"bestTimingInSeconds": kBestTimingInSeconds,
           @"highestStarsCount": kHighestStarsCount,
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


+ (NSString *) filePathForMissionUniqueName:(NSString *) missionUniqueName
                                  forUserId:(NSString *) userId {
  NSString *filename = [NSString stringWithFormat:@"%@-%@.plist", kMissionAggregateFilename, missionUniqueName];
  NSString *filePath = [TPSettings filePathForFilename:filename folderName:userId];
  return filePath;
}

+ (void) missionAggregateResultForMissionUniqueName:(NSString *) missionUniqueName
                                            success:(void (^)(TPMissionAggregateResult *missionAggregateResult))success
                                            failure:(void (^)(NSError *error))failure; {
  
  TPMissionAggregateResult *result = [TPMissionAggregateResult missionAggregateResultForMissionUniqueName:missionUniqueName];
  success(result);
}

+ (instancetype) missionAggregateResultForMissionUniqueName:(NSString *) missionUniqueName {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"User is nil, which is unexpected.");
    return nil;
  }
  
  NSString *filePath = [self filePathForMissionUniqueName:missionUniqueName
                                                forUserId:session.user.userId];
  TPMissionAggregateResult *result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  
  if (result == nil) {
    // Nothing saved yet, initialize and save
    result = [[TPMissionAggregateResult alloc] initWithMissionUniqueName:missionUniqueName
                                                            userUniqueId:session.user.userId];
    [result saveWithErrorDescription:nil queueForUpdate:NO];
  }
  
  return result;
}

+ (NSArray *) missionAggregateResultsFromServerResponse:(NSArray *) serverResponse {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"User is nil, which is unexpected.");
    return nil;
  }

  NSMutableArray *aggregateResults = [NSMutableArray array];
  
  [serverResponse enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *resultDict = (NSDictionary *) obj;
    TPMissionAggregateResult *result = [MTLJSONAdapter modelOfClass:TPMissionAggregateResult.class fromJSONDictionary:resultDict error:nil];
    NSString *filePath = [self filePathForMissionUniqueName:result.missionUniqueName
                                                  forUserId:session.user.userId];
    
    TPMissionAggregateResult *latest = (TPMissionAggregateResult *) [self latestInSession:session persistedFilePath:filePath afterCompareWith:result];
    [aggregateResults addObject:latest];
  }];
  return aggregateResults;
}

+ (NSArray *) missionAggregateResultsFromLocalCopy {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.user == nil) {
    // TODO: Need an error description.
    NSLog(@"User is nil, which is unexpected.");
    return nil;
  }
  
  NSMutableArray *aggregateResults = [NSMutableArray array];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager enumerateFilesInFolder:session.user.userId filterByFilename:kMissionAggregateFilename usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *filePath = (NSString *) obj;
    TPMissionAggregateResult *result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
   
    [aggregateResults addObject:result];
  }];

  return aggregateResults;
}

- (instancetype) initWithMissionUniqueName:(NSString *) missionUniqueName
                              userUniqueId:(NSString *) userUniqueId {
  self = [super init];
  if (self) {
    _resultId = -1;
    _missionUniqueName = [missionUniqueName copy];
    _bestTimingInSeconds = 100000;
    _highestStarsCount = 0;
    _userUniqueId = [userUniqueId copy];
  }
  return self;
}

- (void) updateAggregateResultWithMissionResult:(TPMissionResult *) result {
  [self updateStatsForMissionResult:result];
}

#pragma mark - Concrete TPLocalSerializable methods

- (void) willSaveToServerInSession:(TPSessionService *) session {
  if (self.userUniqueId == nil || [self.userUniqueId isEqualToString:@""]) {
    assert(session.user.userId != nil && ![session.user.userId isEqualToString:@""]);
    self.userUniqueId = session.user.userId;
  }
}

- (TPLocalSerializableModel *) didSaveToServerInSession:(TPSessionService *) session
                                           withResponse:(id) responseObject {
  
  NSDictionary *resultsResponse = [responseObject valueForKey:kTPDataResponseKey];
  NSError *error;
  TPMissionAggregateResult *result = [MTLJSONAdapter modelOfClass:TPMissionAggregateResult.class fromJSONDictionary:resultsResponse error:&error];
  
  return result;
}

- (BOOL) isFirstTimeSave {
  return (self.resultId == -1);
}

- (NSString *) localSaveFilePath {
  return [TPMissionAggregateResult filePathForMissionUniqueName:self.missionUniqueName
                                                      forUserId:self.userUniqueId];
}

- (NSString *) saveToUrlInSession:(TPSessionService *) session {
  NSString *url = [kTPAggregateMissionResultsUrlRoot stringByReplacingOccurrencesOfString:@"MISSIONUNIQUENAME" withString:self.missionUniqueName];
  return [NSString stringWithFormat:@"%@%@", [session gameServiceBaseURL], url];
}

- (NSString *) updateUrlInSession:(TPSessionService *) session {
  NSString *url = [kTPAggregateMissionResultsUrlRoot stringByReplacingOccurrencesOfString:@"MISSIONUNIQUENAME" withString:self.missionUniqueName];
  
  return [NSString stringWithFormat:@"%@%@/%ld", [session gameServiceBaseURL], url, (long)self.resultId];
}


#pragma mark - Stat calculations

- (void) updateStatsForMissionResult:(TPMissionResult *) missionResult {
  [self updateBestTimingInSeconds:missionResult.playDuration];
  [self updateHighestStarsCount:missionResult.numberOfStars];
  [self updateDailyStatsForDate:missionResult.playedAt];
}

- (void) updateBestTimingInSeconds:(NSTimeInterval) playDuration {
  if (playDuration < self.bestTimingInSeconds) {
    self.bestTimingInSeconds = playDuration;
  }
}

- (void) updateHighestStarsCount:(NSInteger) numberOfStars {
  if (numberOfStars > self.highestStarsCount) {
    self.highestStarsCount = numberOfStars;
  }
}

@end
