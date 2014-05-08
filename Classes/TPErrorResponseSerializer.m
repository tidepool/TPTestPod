//
//  TPErrorResponseSerializer.m
//  Pods
//
//  Created by Kerem Karatal on 2/4/14.
//


#import "TPErrorResponseSerializer.h"
#import "TPCommon.h"

@implementation TPErrorResponseSerializer 

static NSString * const kStatus = @"status";
static NSString * const kCode = @"code";
static NSString * const kMessage = @"message";
static NSString * const kNSLocalizedDescription = @"NSLocalizedDescription";

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
  id JSONObject = [super responseObjectForResponse:response data:data error:error]; // may mutate `error`
  
  if (*error != nil) {
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    if (nil == data) {
      [userInfo setValue:[NSData data] forKey:kTPOriginalErrorResponseBody];
      NSLog(@"Failure: (no response body) %@", [userInfo valueForKey:kNSLocalizedDescription]);
    } else {
      NSDictionary *errorInfo = [self errorInfoFromResponseBody:data];
      [userInfo setValue:data forKey:kTPOriginalErrorResponseBody];
      [userInfo setValue:[errorInfo valueForKey:kTPFailureCode] forKey:kTPFailureCode];
      [userInfo setValue:[errorInfo valueForKey:kTPUserFriendlyErrorMessage] forKey:kTPUserFriendlyErrorMessage];
    }
    NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
    (*error) = newError;
  }
  
  return JSONObject;
}

- (NSDictionary *) errorInfoFromResponseBody:(NSData *) bodyData {
  NSError *jsonError = nil;
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:bodyData
                                                           options:kNilOptions
                                                             error:&jsonError];
  
  NSDictionary *errorInfo = nil;
  if (jsonError) {
    NSLog(@"Unrecognized error response: %@", [jsonError description]);
    errorInfo = @{kTPFailureCode: @(kUnknownServerError),
                  kTPUserFriendlyErrorMessage: @"Unknown server error happened."
                  };
  } else {
    NSDictionary *status = [response objectForKey:kStatus];    
    if (status && [status isKindOfClass:[NSDictionary class]]) {
      NSNumber *failureCode = [status objectForKey:kCode];
      if (nil == failureCode) {
        failureCode = [NSNumber numberWithInteger:0];
      }
      NSString *message = [status objectForKey:kMessage];
      if (nil == message) {
        message = @"Unknown error.";
      }
      
      errorInfo = @{kTPFailureCode: failureCode,
                    kTPUserFriendlyErrorMessage: message
                    };
      
      NSLog(@"Failure Code: %@", failureCode);
      NSLog(@"Failure Message: %@", message);
    } else {
      NSLog(@"Unrecognized error response: %@", [response description]);
      errorInfo = @{kTPFailureCode: @(kUnknownServerError),
                    kTPUserFriendlyErrorMessage: @"Unknown server error happened."
                    };
      
    }
  }
  return errorInfo;
}


@end
