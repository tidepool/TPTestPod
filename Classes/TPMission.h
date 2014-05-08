//
//  TPMission.h
//  Pods
//
//  Created by Kerem Karatal on 3/5/14.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "TPCommon.h"

@interface TPMission : MTLModel<MTLJSONSerializing>

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *uniqueName;
@property(nonatomic, copy) NSString *missionId;
@property(nonatomic, assign) NSInteger missionOrdinal;
@property(nonatomic, readonly) NSURL *backgroundImageURL;
@property(nonatomic, copy) NSString *shortDescription;
@property(nonatomic, copy) NSString *longDescription;

@property(nonatomic, strong) NSArray *stages;
@property(nonatomic, strong) NSArray *requirements;

- (NSTimeInterval) maxDuration;
@end
