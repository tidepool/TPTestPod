//
//  TPStoryScreen.h
//  Pods
//
//  Created by Kerem Karatal on 4/2/14.
//
//

#import <Mantle/Mantle.h>

@interface TPStoryScreen : MTLModel<MTLJSONSerializing>
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *storyLine;
@property(nonatomic, strong) NSURL *backgroundImageURL;
@end
