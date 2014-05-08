//
//  TPGame.m
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//
//

#import "TPGame.h"

static NSString * const kUniqueName = @"name";
static NSString * const kMaxPossibleScore = @"max_possible_score";
static NSString * const kCognitivePercentages = @"cognitive_percentages";

@implementation TPGame

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"uniqueName": kUniqueName,
           @"maxPossibleScore": kMaxPossibleScore,
           @"cognitivePercentages": kCognitivePercentages
           };
}

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (NSArray *) relevantCognitivePercentageKeys {
  NSMutableArray *relevantKeys = [NSMutableArray array];
  [self.cognitivePercentages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    NSNumber *percentage = (NSNumber *) obj;
    if (percentage != nil && (NSNull *)percentage != [NSNull null]) {
      float percentageValue = [percentage floatValue];
      if (percentageValue > 0) {
        [relevantKeys addObject:key];
      }
    }
  }];
  return relevantKeys;
}

@end
