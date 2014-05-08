//
//  TPGameList.h
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//
//

#import <Foundation/Foundation.h>

@class TPGame;
@interface TPGameList : NSObject
@property(nonatomic, strong) NSArray *games;

+ (instancetype) sharedInstance;
- (TPGame *) gameByUniqueName:(NSString *) gameUniqueName;

@end
