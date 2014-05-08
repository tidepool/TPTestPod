//
//  TPMission.m
//  Pods
//
//  Created by Kerem Karatal on 3/5/14.
//
//

#import "TPMission.h"
#import "TPSettings.h"
#import "TPSessionService.h"
#import "TPGameRequirement.h"
#import "TPMissionStage.h"

static NSString * const kTitle = @"title";
static NSString * const kUniqueName = @"unique_name";
static NSString * const kMissionId = @"id";
static NSString * const kMissionOrdinal = @"mission_ordinal";
static NSString * const kBackgroundImage = @"background_image";
static NSString * const kShortDescription = @"short_description";
static NSString * const kLongDescription = @"long_description";
static NSString * const kRequirements = @"requirements";

@implementation TPMission

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"missionId": kMissionId,
           @"uniqueName": kUniqueName,
           @"missionOrdinal": kMissionOrdinal,
           @"backgroundImageURL": kBackgroundImage,
           @"shortDescription": kShortDescription,
           @"longDescription": kLongDescription,
           @"requirements": kRequirements
           };
}

+ (NSValueTransformer *) stagesJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:TPMissionStage.class];
}

+ (NSValueTransformer *) requirementsJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:TPGameRequirement.class];
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

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (NSTimeInterval) maxDuration {
  __block NSTimeInterval duration = 0;
  [self.stages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPMissionStage *stage = (TPMissionStage *) obj;
    duration += stage.gameConfig.duration;
  }];
  return duration;
}

@end
