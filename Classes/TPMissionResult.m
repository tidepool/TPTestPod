//
//  TPMissionResult.m
//  Pods
//
//  Created by Kerem Karatal on 3/6/14.
//
//

#import "TPMissionResult.h"
#import "TPMission.h"

@implementation TPMissionResult

+ (instancetype) missionResultForMission:(TPMission *) mission withBlock:(TPMissionResultBlock) block {
  NSParameterAssert(mission);
  NSParameterAssert(block);
  TPMissionResult *result = [[self alloc] init];
  result.missionUniqueName = mission.uniqueName;
  block(result);
  return result;
}

@end
