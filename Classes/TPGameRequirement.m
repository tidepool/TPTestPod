//
//  TPGameRequirement.m
//  Pods
//
//  Created by Kerem Karatal on 4/10/14.
//
//

#import "TPGameRequirement.h"

static NSString * const kGameUniqueName = @"game_unique_name";
static NSString * const kPlayCount = @"play_count";

@implementation TPGameRequirement

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"gameUniqueName": kGameUniqueName,
           @"playCount": kPlayCount
           };
}

@end
