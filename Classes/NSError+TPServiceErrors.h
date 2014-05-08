//
//  NSError+TPServiceErrors.h
//  Pods
//
//  Created by Kerem Karatal on 4/21/14.
//
//

#import <Foundation/Foundation.h>

@interface NSError (TPServiceErrors)
+ (instancetype) errorWithFailureCode:(NSInteger) failureCode
                  userFriendlyMessage:(NSString *) message;

- (NSInteger) failureCode;
- (NSString *) userFriendlyMessage;
@end
