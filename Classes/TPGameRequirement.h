//
//  TPGameRequirement.h
//  Pods
//
//  Created by Kerem Karatal on 4/10/14.
//
//

#import <Mantle/Mantle.h>

@interface TPGameRequirement : MTLModel<MTLJSONSerializing>
@property(nonatomic, copy) NSString *gameUniqueName;
@property(nonatomic, assign) NSInteger playCount;
@end
