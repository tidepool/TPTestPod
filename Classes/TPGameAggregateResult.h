//
//  TPGameAggregateResult.h
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import "TPAggregateResult.h"
#import "TPGameResult.h"

@interface TPGameAggregateResult : TPAggregateResult

@property(nonatomic, assign) NSInteger resultId;
@property(nonatomic, copy) NSString *gameUniqueName;
@property(nonatomic, copy) NSString *userUniqueId;

// Game Stats
@property(nonatomic, assign) double highScore;
@property(nonatomic, assign) NSInteger highestLevel;

+ (void) aggregateResultForGameName:(NSString *) gameUniqueName
                            success:(void (^)(TPGameAggregateResult *gameAggregateResult))success
                            failure:(void (^)(NSError *error))failure;

+ (instancetype) gameAggregateResultForGameUniqueName:(NSString *) gameUniqueName;
+ (NSArray *) gameAggregateResultsFromServerResponse:(NSArray *) serverResponse;
+ (NSArray *) gameAggregateResultsFromLocalCopy;

- (instancetype) initWithGameUniqueName:(NSString *) gameUniqueName
                           userUniqueId:(NSString *) userUniqueId;

- (void) updateAggregateResultWithGameResult:(TPGameResult *) result;

@end
