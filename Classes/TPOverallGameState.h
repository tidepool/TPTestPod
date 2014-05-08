//
//  TPOverallGameState.h
//  Pods
//
//  Created by Kerem Karatal on 4/30/14.
//
//

#import <Foundation/Foundation.h>

@class TPAgentProgress;
@interface TPOverallGameState : NSObject
@property (nonatomic, strong) TPAgentProgress *agentProgress;

+ (instancetype) sharedInstance;
@end
