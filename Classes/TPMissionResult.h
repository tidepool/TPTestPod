//
//  TPMissionResult.h
//  Pods
//
//  Created by Kerem Karatal on 3/6/14.
//
//

#import <Foundation/Foundation.h>

@class TPMission;
@class TPMissionResult;
typedef void(^TPMissionResultBlock)(TPMissionResult *missionResult);

@interface TPMissionResult : NSObject
@property(nonatomic, strong) NSString *missionUniqueName;
@property(nonatomic, assign) NSInteger numberOfStars;
@property(nonatomic, strong) NSDate *playedAt;
@property(nonatomic, assign) NSTimeInterval playDuration;

+ (instancetype) missionResultForMission:(TPMission *) mission withBlock:(TPMissionResultBlock) block;

@end
