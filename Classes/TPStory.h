//
//  TPStory.h
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import <Mantle/Mantle.h>

@interface TPStory : MTLModel<MTLJSONSerializing>
@property(nonatomic, strong) NSArray *screens;
@end
