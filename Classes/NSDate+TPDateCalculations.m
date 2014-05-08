//
//  NSDate+TPDateCalculations.m
//  Pods
//
//  Created by Kerem Karatal on 4/8/14.
//
//

#import "NSDate+TPDateCalculations.h"

@implementation NSDate (TPDateCalculations)
- (BOOL) isSameDayOfYearAsDate:(NSDate *)otherDate {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:self toDate:otherDate options:0];

  BOOL isSameDayOfYear = NO;
  if (components.day == 0) {
    isSameDayOfYear = YES;
  }
  return isSameDayOfYear;
}

- (BOOL) isSameWeekOfYearAsDate:(NSDate *)otherDate {
  NSCalendar *calendar = [NSCalendar currentCalendar];
//  NSDateComponents *components = [calendar components:NSWeekOfYearCalendarUnit fromDate:self toDate:otherDate options:0];
//  
//  BOOL isSameWeekOfYear = NO;
//  if (components.weekOfYear == 0) {
//    isSameWeekOfYear = YES;
//  }
  NSDateComponents *components = [calendar components:NSWeekOfYearCalendarUnit fromDate:self];
  NSInteger thisWeekOfYear = components.weekOfYear;
  
  components = [calendar components:NSWeekOfYearCalendarUnit fromDate:otherDate];
  NSInteger otherWeekOfYear = components.weekOfYear;
  
  BOOL isSameWeekOfYear = NO;
  if (thisWeekOfYear == otherWeekOfYear) {
    isSameWeekOfYear = YES;
  }
  return isSameWeekOfYear;
}
@end
