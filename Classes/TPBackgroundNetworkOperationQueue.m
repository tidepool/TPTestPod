//
//  TPBackgroundNetworkOperationQueue.m
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import "TPBackgroundNetworkOperationQueue.h"
#import "TPSettings.h"
#import "TPSessionService.h"

static NSString * const kOperationQueueFilename = @"TPOperationQueue.plist";
static NSString * const kOperationsMarkedForRemovalFilename = @"TPOperationsMarkedForRemoval.plist";


@interface TPBackgroundNetworkOperationQueue()
@property(nonatomic, strong) NSMutableArray *operations;
@property(nonatomic, strong) NSMutableArray *operationsMarkedForRemoval;
@end

@implementation TPBackgroundNetworkOperationQueue

+ (NSString *) filePathForFilename:(NSString *) filename {
  TPSessionService *session = [TPSessionService sharedInstance];
  NSString *filePath = [TPSettings filePathForFilename:filename folderName:session.user.userId];
  
  return filePath;
}

+ (instancetype) sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    NSArray *operationsInQueue = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForFilename:kOperationQueueFilename]];
    NSArray *operationsMarkedForRemoval = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForFilename:kOperationsMarkedForRemovalFilename]];
    
    sharedInstance = [[self alloc] initWithOperationsInQueue:operationsInQueue
                                  operationsMarkedForRemoval:operationsMarkedForRemoval];
    
  });
  return sharedInstance;
}

- (instancetype) initWithOperationsInQueue:(NSArray *) operations
                operationsMarkedForRemoval:(NSArray *) operationsMarkedForRemoval {
  self = [super init];
  if (self) {
    _operationsMarkedForRemoval = [NSMutableArray arrayWithArray:operationsMarkedForRemoval];
    _operations = [NSMutableArray arrayWithArray:operations];
  }
  return self;
}

- (void) addOperation:(TPBackgroundNetworkOperation *) operation tryFlushing:(BOOL) tryFlushing{
  [self ifNeededRemoveDuplicateOperation:operation fromArray:self.operations];
  [self.operations addObject:operation];
  if (tryFlushing) {
    [self tryFlush];
  }
  [self saveOperationQueue];
}

- (void) removeOperation:(TPBackgroundNetworkOperation *) operation {
  [self.operations removeObject:operation];
}

- (NSInteger) operationsCount {
  return [self.operations count];
}

- (void) tryFlush {
  TPSessionService *session = [TPSessionService sharedInstance];
  if (session.workOfflineOnly) {
    return;
  }
  [self iterateOverOperations];
}

- (void) iterateOverOperations {
  [self cleanupOperationQueueByRemovingOperationsMarkedForRemoval];
  [self.operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    TPBackgroundNetworkOperation *operation = (TPBackgroundNetworkOperation *) obj;
    
    switch (operation.operationType) {
      case TPSaveOperation:
      {
        [operation.model saveSuccess:^(MTLModel *model) {
          NSLog(@"Operation %@ completed.", operation.name);
          [self markForRemovalOperation:operation];
        } failure:^(NSError *error) {
          NSLog(@"Error operation %@, Message: %@", operation.name, [error description]);
        }];
        break;
      }
      default:
        break;
    }
  }];
}

- (void) markForRemovalOperation:(TPBackgroundNetworkOperation *) operation {
  [self ifNeededRemoveDuplicateOperation:operation fromArray:self.operationsMarkedForRemoval];
  [self.operationsMarkedForRemoval addObject:operation];
  [self saveMarkedForRemovalQueue];
}

- (void) cleanupOperationQueueByRemovingOperationsMarkedForRemoval {
  [self.operations removeObjectsInArray:self.operationsMarkedForRemoval];
  [self.operationsMarkedForRemoval removeAllObjects];
}

- (BOOL) saveOperationQueue {
  BOOL saved = [NSKeyedArchiver archiveRootObject:self.operations
                                           toFile:[TPBackgroundNetworkOperationQueue filePathForFilename:kOperationQueueFilename]];
  
  return saved;
}

- (BOOL) saveMarkedForRemovalQueue {
  BOOL saved = [NSKeyedArchiver archiveRootObject:self.operations
                                           toFile:[TPBackgroundNetworkOperationQueue filePathForFilename:kOperationsMarkedForRemovalFilename]];
  
  return saved;
}

- (void) ifNeededRemoveDuplicateOperation:(TPBackgroundNetworkOperation *)operation fromArray:(NSArray *) anArray {
  // Assumption is that this operation queue is not that big normally
  if (!operation.duplicationAllowed) {
    [self.operations removeObject:operation];
  }
}


@end
