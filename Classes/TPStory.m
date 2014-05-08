//
//  TPStory.m
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import "TPStory.h"
#import "TPStoryScreen.h"

static NSString * const kScreens = @"screens";

@implementation TPStory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"screens": kScreens
           };
}

+ (NSValueTransformer *) screensJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:TPStoryScreen.class];
}

@end
