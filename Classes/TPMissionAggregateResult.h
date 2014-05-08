//
//  TPMissionAggregateResult.h
//  Pods
//
//  Created by Kerem Karatal on 4/18/14.
//
//

#import "TPAggregateResult.h"
#import "TPMissionResult.h"

@interface TPMissionAggregateResult : TPAggregateResult

@property(nonatomic, assign, readonly) NSInteger resultId;
@property(nonatomic, copy) NSString *missionUniqueName;
@property(nonatomic, copy) NSString *userUniqueId;

// Game Stats
@property(nonatomic, assign) NSTimeInterval bestTimingInSeconds;
@property(nonatomic, assign) NSInteger highestStarsCount;

+ (void) missionAggregateResultForMissionUniqueName:(NSString *) missionUniqueName
                                            success:(void (^)(TPMissionAggregateResult *missionAggregateResult))success
                                            failure:(void (^)(NSError *error))failure;
+ (instancetype) missionAggregateResultForMissionUniqueName:(NSString *) missionUniqueName;

+ (NSArray *) missionAggregateResultsFromServerResponse:(NSArray *) serverResponse;
+ (NSArray *) missionAggregateResultsFromLocalCopy;

- (void) updateAggregateResultWithMissionResult:(TPMissionResult *) result;

@end
