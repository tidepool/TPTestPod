//
//  TPAggregateResult.m
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//
//

#import "TPAggregateResult.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "NSDate+TPDateCalculations.h"

#import <Mantle/MTLJSONAdapter.h>

@implementation TPAggregateResult

- (instancetype) init {
  self = [super init];
  if (self) {
    _maxNumberOfTimesPlayedInOneDay = 0;
    _maxNumberOfTimesPlayedInOneWeek = 0;
    _numberOfTimesPlayedToday = 0;
    _numberOfTimesPlayedThisWeek = 0;
    _numberOfTimesPlayedTotal = 0;
    _lastPlayedAt = [NSDate distantPast];
    _extraResultData = nil;
  }
  return self;
}

#pragma mark - Stat calculations

- (void) updateDailyStatsForDate:(NSDate *) date {
  [self updateMaxNumberOfTimesPlayedInOneDay];
  [self updateMaxNumberOfTimesPlayedInOneWeek];
  _numberOfTimesPlayedTotal += 1;
  
  // Always update lastPlayedAt last, prior calculations depend on this value.
  _lastPlayedAt = date;
}

- (void) updateMaxNumberOfTimesPlayedInOneDay {
  [self updateMaxNumberOfTimesPlayedInOneDay:[NSDate dateWithTimeIntervalSinceNow:0]
                            whenLastPlayedAt:self.lastPlayedAt];
}

- (void) updateMaxNumberOfTimesPlayedInOneDay:(NSDate *) date
                             whenLastPlayedAt:(NSDate *) lastPlayedAt {
  BOOL isSameDay = [date isSameDayOfYearAsDate:lastPlayedAt];
  
  if (isSameDay) {
    _numberOfTimesPlayedToday += 1;
  } else {
    _numberOfTimesPlayedToday = 1;
  }
  if (self.numberOfTimesPlayedToday > self.maxNumberOfTimesPlayedInOneDay) {
    _maxNumberOfTimesPlayedInOneDay = self.numberOfTimesPlayedToday;
  }
}

- (void) updateMaxNumberOfTimesPlayedInOneWeek {
  [self updateMaxNumberOfTimesPlayedInOneWeek:[NSDate dateWithTimeIntervalSinceNow:0]
                             whenLastPlayedAt:self.lastPlayedAt];
}

- (void) updateMaxNumberOfTimesPlayedInOneWeek:(NSDate *) date
                              whenLastPlayedAt:(NSDate *) lastPlayedAt {
  BOOL isSameWeek = [date isSameWeekOfYearAsDate:lastPlayedAt];
  
  if (isSameWeek) {
    _numberOfTimesPlayedThisWeek += 1;
  } else {
    _numberOfTimesPlayedThisWeek = 1;
  }
  if (self.numberOfTimesPlayedThisWeek > self.maxNumberOfTimesPlayedInOneWeek) {
    _maxNumberOfTimesPlayedInOneWeek = self.numberOfTimesPlayedThisWeek;
  }
}
@end
