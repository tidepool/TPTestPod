//
//  TPStoryScreen.m
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import "TPStoryScreen.h"
#import "TPSessionService.h"

static NSString * const kTitle = @"title";
static NSString * const kStoryLine = @"story_line";
static NSString * const kBackgroundImageURL = @"background_image";

@implementation TPStoryScreen

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"storyLine": kStoryLine,
           @"backgroundImageURL": kBackgroundImageURL
           };
}

+ (NSValueTransformer *) backgroundImageURLJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
    if (![str isKindOfClass:NSString.class] || str == nil) return nil;
    NSRange range = [str rangeOfString:@"http"];
    NSString *imageURL = nil;
    if (range.location == NSNotFound) {
      TPSessionService *session = [TPSessionService sharedInstance];
      imageURL = [NSString stringWithFormat:@"%@%@", [session imageBaseURL], str];
    } else {
      imageURL = str;
    }
    return [NSURL URLWithString:imageURL];
  } reverseBlock:^(NSURL *imageURL) {
    return [imageURL absoluteString];
  }];
}

@end
