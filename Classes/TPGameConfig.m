//
//  TPGame.m
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import "TPGameConfig.h"

static NSString * const kGameId = @"game_id";
static NSString * const kDuration = @"duration";
static NSString * const kStartLevel = @"start_level";
static NSString * const kLevelsToBeat = @"levels_to_beat";

@implementation TPGameConfig

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"gameId": kGameId,
           @"duration": kDuration,
           @"levelsToBeat": kLevelsToBeat,
           @"startLevel": kStartLevel
           };
}

@end
