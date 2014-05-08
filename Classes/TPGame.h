//
//  TPGame.h
//  Pods
//
//  Created by Kerem Karatal on 4/22/14.
//

#import <Mantle/Mantle.h>

@interface TPGame : MTLModel<MTLJSONSerializing>
@property(nonatomic, copy) NSString *uniqueName;
@property(nonatomic, assign) double maxPossibleScore;
@property(nonatomic, strong) NSDictionary *cognitivePercentages;

- (NSArray *) relevantCognitivePercentageKeys;

@end
