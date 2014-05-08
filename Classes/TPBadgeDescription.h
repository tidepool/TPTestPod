//
//  TPBadgeDescription.h
//  Pods
//
//  Created by Kerem Karatal on 4/29/14.
//
//

#import <Foundation/Foundation.h>

@interface TPBadgeDescription : NSObject

@property(nonatomic, copy, readonly) NSString *uniqueName;
@property(nonatomic, assign, readonly) NSInteger numberOfTimesEarned;
@property(nonatomic, strong, readonly) NSDate *lastEarnedAt;

- (instancetype)initWithUniqueName:(NSString *) uniqueName
               numberOfTimesEarned:(NSInteger) timesEarned
                      lastEarnedAt:(NSDate *) lastEarnedAt;

@end
