//
//  TPLeader.h
//  Pods
//
//  Created by Kerem Karatal on 4/11/14.
//
//

#import <Mantle/Mantle.h>
#import "TPCommon.h"

@interface TPLeader : MTLModel<MTLJSONSerializing>
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSURL *profilePhotoURL;
@property(nonatomic, assign) float score;
@property(nonatomic, copy) NSString *userId;

+ (void) findByLeaderboardId:(NSString *) leaderboardId
                    pageInfo:(TPPageInfo) pageInfo
                     success:(void (^)(NSArray *leaders, TPPageInfo pageInfo))success
                     failure:(void (^)(NSError *error))failure;
@end
