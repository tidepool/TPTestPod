//
//  TPGameResult.m
//  Pods
//
//  Created by Kerem Karatal on 3/6/14.
//
//

#import "TPGameResult.h"
#import "TPGame.h"
#import "TPSettings.h"

static NSString * const kGameResultId = @"id";
static NSString * const kGameId = @"game_id";
static NSString * const kGameUniqueName = @"game_unique_name";
static NSString * const kUserUniqueId = @"user_unique_id";
static NSString * const kPlayedAs = @"played_as";
static NSString * const kPlayedAt = @"played_at";
static NSString * const kConanicalScore = @"conanical_score";
static NSString * const kLevelCompleted = @"level_completed";
static NSString * const kBonusPoints = @"bonus_points";
static NSString * const kExtraResultData = @"extra_result_data";

@implementation TPGameResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"resultId": kGameResultId,
           @"gameId": kGameId,
           @"gameUniqueName": kGameUniqueName,
           @"userUniqueId": kUserUniqueId,
           @"playedAs": kPlayedAs,
           @"playedAt": kPlayedAt,
           @"conanicalScore": kConanicalScore,
           @"levelCompleted": kLevelCompleted,
           @"bonusPoints": kBonusPoints,
           @"extraResultData": kExtraResultData
           };
}

+ (NSValueTransformer *) playedAtJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [[TPSettings dateFormatter] dateFromString:str];
  } reverseBlock:^(NSDate *date) {
    return [[TPSettings dateFormatter] stringFromDate:date];
  }];
}

+ (NSValueTransformer *) playedAsJSONTransformer {
  return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                         @"training": @(TPPlayedAsTraining),
                                                                         @"mission": @(TPPlayedAsMission)
                                                                         }];
}

//+ (instancetype) gameResultWithGameName:(NSString *) uniqueName withBlock:(TPGameResultBlock) block {
//  NSParameterAssert(uniqueName);
//  NSParameterAssert(block);
//  TPGameResult *result = [[self alloc] init];
//  result.gameUniqueName = uniqueName;
//  block(result);
//  return result;
//}

+ (instancetype) gameResultForGame:(TPGame *) game withBlock:(TPGameResultBlock) block {
  NSParameterAssert(game);
  NSParameterAssert(block);
  TPGameResult *result = [[self alloc] init];
  result.gameUniqueName = game.uniqueName;
  block(result);
  return result;
}

@end
