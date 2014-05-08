//
//  TPMissionList.h
//  Pods
//
//  Created by Kerem Karatal on 4/18/14.
//
//

#import <Foundation/Foundation.h>

@class TPMission;
@interface TPMissionList : NSObject
@property(nonatomic, strong) NSArray *missions;

+ (instancetype) sharedInstance;

- (TPMission *) missionByUniqueName:(NSString *) missionUniqueName;

@end
