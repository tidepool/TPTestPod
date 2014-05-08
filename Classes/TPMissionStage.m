//
//  TPMissionStage.m
//  Pods
//
//  Created by Kerem Karatal on 3/10/14.
//
//

#import "TPMissionStage.h"
#import "TPSessionService.h"

static NSString * const kTitle = @"title";
static NSString * const kGameConfig = @"game";
static NSString * const kHeaderStory = @"header_story";
static NSString * const kFooterStory = @"footer_story";

@implementation TPMissionStage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"headerStory": kHeaderStory,
           @"footerStory": kFooterStory,
           @"gameConfig": kGameConfig
           };
}


+ (NSValueTransformer *)gameConfigJSONTransformer {
  return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:TPGameConfig.class];
}

+ (NSValueTransformer *)headerStoryJSONTransformer {
  return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:TPStory.class];
}

+ (NSValueTransformer *)footerStoryJSONTransformer {
  return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:TPStory.class];
}

@end
