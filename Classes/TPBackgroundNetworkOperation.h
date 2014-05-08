//
//  TPBackgroundNetworkOperation.h
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>

typedef enum : NSUInteger {
  TPSaveOperation,
  TPReadOperation
} TPBackgroundNetworkOperationType;

@protocol TPBackgroundNetworkOperationTasks
- (void) saveSuccess:(void (^)(MTLModel *model))success
             failure:(void (^)(NSError *error))failure;
@end

@interface TPBackgroundNetworkOperation : NSObject<NSCoding>
@property(atomic, strong, readonly) MTLModel<TPBackgroundNetworkOperationTasks> *model;
@property(atomic, assign, readonly) TPBackgroundNetworkOperationType operationType;
@property(atomic, assign, readonly) BOOL duplicationAllowed;
@property(atomic, copy, readonly) NSString *name;
@property(atomic, strong, readonly) NSDictionary *params;

- (instancetype) initWithModel:(MTLModel<TPBackgroundNetworkOperationTasks> *) model
                 operationType:(TPBackgroundNetworkOperationType) operationType
            duplicationAllowed:(BOOL) duplicationAllowed;

- (instancetype) initWithModel:(MTLModel<TPBackgroundNetworkOperationTasks> *) model
                        params:(NSDictionary *) params
                 operationType:(TPBackgroundNetworkOperationType) operationType
            duplicationAllowed:(BOOL) duplicationAllowed;

@end
