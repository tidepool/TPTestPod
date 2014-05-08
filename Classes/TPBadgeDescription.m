//
//  TPBadgeDescription.m
//  Pods
//
//  Created by Kerem Karatal on 4/29/14.
//
//

#import "TPBadgeDescription.h"

@implementation TPBadgeDescription

- (instancetype)initWithUniqueName:(NSString *) uniqueName
               numberOfTimesEarned:(NSInteger) timesEarned
                      lastEarnedAt:(NSDate *) lastEarnedAt {
  self = [super init];
  if (self) {
    _uniqueName = [uniqueName copy];
    _numberOfTimesEarned = timesEarned;
    _lastEarnedAt = lastEarnedAt;
  }
  return self;
}
@end
