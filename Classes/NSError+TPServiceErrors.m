//
//  NSError+TPServiceErrors.m
//  Pods
//
//  Created by Kerem Karatal on 4/21/14.
//
//

#import "NSError+TPServiceErrors.h"
#import "TPCommon.h"

@implementation NSError (TPServiceErrors)

+ (instancetype) errorWithFailureCode:(NSInteger) failureCode
                  userFriendlyMessage:(NSString *) message {
  NSError *error = [NSError errorWithDomain:kTPSessionErrorDomain
                                       code:1000
                                   userInfo:@{kTPFailureCode: @(failureCode),
                                              kTPUserFriendlyErrorMessage: message
                                              }];
  
  return error;
}

- (NSInteger) failureCode {
  NSInteger failureCode = kUnknownServerError;
  NSNumber *failureCodeNumber = [[self userInfo] objectForKey: kTPFailureCode];
  if (failureCodeNumber) {
    failureCode = [failureCodeNumber integerValue];
  }
  return failureCode;
}

- (NSString *) userFriendlyMessage {
  NSString *message = [[self userInfo] objectForKey:kTPUserFriendlyErrorMessage];
  if (message == nil) {
    message = @"Unknown service error.";
  }
  
  return message;
}

@end
