//
//  TPErrorResponseSerializer.h
//  Pods
//
//  Created by Kerem Karatal on 2/4/14.
//
//  This is taken from https://github.com/AFNetworking/AFNetworking/issues/1397 and http://blog.gregfiumara.com/archives/239
//  Unfortunately, AFNetworking 2.0+ does not give you the response body in the failure block.
//
//

// NSError userInfo key that will contain response data


#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TPErrorResponseSerializer : AFJSONResponseSerializer

@end
