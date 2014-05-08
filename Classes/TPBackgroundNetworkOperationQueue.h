//
//  TPBackgroundNetworkOperationQueue.h
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import <Foundation/Foundation.h>
#import "TPBackgroundNetworkOperation.h"

@interface TPBackgroundNetworkOperationQueue : NSObject
+ (instancetype) sharedInstance;
- (void) addOperation:(TPBackgroundNetworkOperation *) operation tryFlushing:(BOOL) tryFlushing;
- (void) removeOperation:(TPBackgroundNetworkOperation *) operation;
- (NSInteger) operationsCount;
- (void) tryFlush;
@end
