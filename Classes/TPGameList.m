//
//  TPGameList.m
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//
//

#import "TPGameList.h"
#import "TPSettings.h"
#import "TPGame.h"
#import "TPSessionService.h"

#import <Mantle/MTLJSONAdapter.h>

@implementation TPGameList

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
    _games = [self readFromResourceBundle];
  }
  return self;
}

- (TPGame *) gameByUniqueName:(NSString *) gameUniqueName {
  // O(N) search for now...
  __block TPGame *foundGame = nil;
  [self.games enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPGame *game = (TPGame *) obj;
    if ([game.uniqueName isEqualToString:gameUniqueName]) {
      foundGame = game;
      *stop = YES;
    }
  }];
  return foundGame;
}

- (NSArray *) readFromResourceBundle {
  NSString *filePath = [[NSBundle bundleForClass: [TPGameList class]] pathForResource:@"sample_game" ofType:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
  NSMutableArray *games = [NSMutableArray array];
  
  NSError *error;
  NSArray *gamesJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
  [gamesJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSError *error;
    TPGame *game = [MTLJSONAdapter modelOfClass:TPGame.class fromJSONDictionary:obj error:&error];
    
    [games addObject:game];
  }];
  return games;
}

@end
