//
//  TPMissionStage.h
//  Pods
//
//  Created by Kerem Karatal on 3/10/14.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "TPCommon.h"
#import "TPGameConfig.h"
#import "TPStory.h"

@interface TPMissionStage : MTLModel <MTLJSONSerializing>
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) TPGameConfig *gameConfig;
@property(nonatomic, strong) TPStory *headerStory;
@property(nonatomic, strong) TPStory *footerStory;
@end
