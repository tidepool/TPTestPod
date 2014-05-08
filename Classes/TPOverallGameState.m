//
//  TPOverallGameState.m
//  Pods
//
//  Created by Kerem Karatal on 4/30/14.
//
//

#import "TPOverallGameState.h"
#import "TPAgentProgress.h"

@implementation TPOverallGameState

+ (instancetype) sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
    sharedInstance = [[self alloc] initWithAgentProgress:(TPAgentProgress *) agentProgress];
  });
  return sharedInstance;
}

- (instancetype) initWithAgentProgress:(TPAgentProgress *) agentProgress {
  self = [super init];
  if (self) {
    _agentProgress = agentProgress;
  }
  return self;
}

@end
