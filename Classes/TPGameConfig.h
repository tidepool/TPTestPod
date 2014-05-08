//
//  TPGame.h
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import <Mantle/Mantle.h>

@interface TPGameConfig : MTLModel<MTLJSONSerializing>

@property(nonatomic, copy) NSString *gameId;
@property(nonatomic, assign) NSTimeInterval duration;
@property(nonatomic, assign) NSUInteger startLevel;
@property(nonatomic, assign) NSUInteger levelsToBeat;
@end
