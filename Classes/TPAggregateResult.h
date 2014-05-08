//
//  TPAggregateResult.h
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//
//

#import "TPLocalSerializableModel.h"

@interface TPAggregateResult : TPLocalSerializableModel
@property(nonatomic, strong) NSDictionary *extraResultData;
@property(nonatomic, readonly) NSInteger maxNumberOfTimesPlayedInOneDay;
@property(nonatomic, readonly) NSInteger maxNumberOfTimesPlayedInOneWeek;
@property(nonatomic, readonly) NSInteger numberOfTimesPlayedToday;
@property(nonatomic, readonly) NSInteger numberOfTimesPlayedThisWeek;
@property(nonatomic, readonly) NSInteger numberOfTimesPlayedTotal;
@property(nonatomic, readonly) NSDate *lastPlayedAt;

- (void) updateDailyStatsForDate:(NSDate *) date;

// Open only for unit testing purposes, do not call directly
- (void) updateMaxNumberOfTimesPlayedInOneDay:(NSDate *) date
                             whenLastPlayedAt:(NSDate *) lastPlayedAt;
- (void) updateMaxNumberOfTimesPlayedInOneWeek:(NSDate *) date
                              whenLastPlayedAt:(NSDate *) lastPlayedAt;

@end
