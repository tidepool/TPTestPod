//
//  NSDate+TPDateCalculations.h
//  Pods
//
//  Created by Kerem Karatal on 4/8/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (TPDateCalculations)
- (BOOL) isSameDayOfYearAsDate:(NSDate *)otherDate;
- (BOOL) isSameWeekOfYearAsDate:(NSDate *)otherDate;
@end
