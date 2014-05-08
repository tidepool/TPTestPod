//
//  TPGameResult.h
//  Pods
//
//  Created by Kerem Karatal on 3/6/14.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "TPCommon.h"

typedef enum : NSUInteger {
  TPPlayedAsTraining,
  TPPlayedAsMission
} TPPlayedAs;

@class TPGame;
@class TPGameResult;
typedef void(^TPGameResultBlock)(TPGameResult *gameResult);

@interface TPGameResult :  MTLModel <MTLJSONSerializing>
@property(nonatomic, assign, readonly) NSInteger resultId;
@property(nonatomic, assign) NSInteger gameId;
@property(nonatomic, copy) NSString *gameUniqueName;
@property(nonatomic, copy, readonly) NSString *userUniqueId;
@property(nonatomic, strong) NSDate *playedAt;
@property(nonatomic, assign) TPPlayedAs playedAs;
@property(nonatomic, assign) double conanicalScore;
@property(nonatomic, assign) NSInteger levelCompleted;
@property(nonatomic, assign) double bonusPoints;
@property(nonatomic, strong) NSDictionary *extraResultData;

//+ (instancetype) gameResultWithGameName:(NSString *) uniqueName withBlock:(TPGameResultBlock) block;
+ (instancetype) gameResultForGame:(TPGame *) game withBlock:(TPGameResultBlock) block;

@end


 