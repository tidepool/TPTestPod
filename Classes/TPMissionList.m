//
//  TPMissionList.m
//  Pods
//
//  Created by Kerem Karatal on 4/18/14.
//
//

#import "TPMissionList.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "TPMission.h"

@interface TPMissionList()
@end

@implementation TPMissionList

+ (instancetype) sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (instancetype) init {
  self = [super init];
  if (self) {
    _missions = self.missions = [self readFromResourceBundle];
  }
  return self;
}

- (TPMission *) missionByUniqueName:(NSString *)missionUniqueName {
  // O(N) search for now...
  __block TPMission *foundMission = nil;
  [self.missions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPMission *mission = (TPMission *) obj;
    if (mission.uniqueName == missionUniqueName) {
      foundMission = mission;
      *stop = YES;
    }
  }];
  return foundMission;
}

- (NSArray *) readFromResourceBundle {
  NSString *filePath = [[NSBundle bundleForClass: [TPMissionList class]] pathForResource:@"sample_mission" ofType:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
  NSMutableArray *missions = [NSMutableArray array];
  
  NSError *error;
  NSArray *missionsJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
  [missionsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSError *error;
    TPMission *mission = [MTLJSONAdapter modelOfClass:TPMission.class fromJSONDictionary:obj error:&error];
    
    [missions addObject:mission];
  }];
  return missions;
}

@end
