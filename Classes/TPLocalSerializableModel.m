//
//  TPLocalSerializableModel.m
//  Pods
//
//  Created by Kerem Karatal on 4/16/14.
//
//

#import "TPLocalSerializableModel.h"
#import "TPBackgroundNetworkOperationQueue.h"
#import "TPSessionService.h"
#import <ReactiveCocoa/RACEXTScope.h>

@implementation TPLocalSerializableModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return nil;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _updatedAt = [NSDate distantPast];
  }
  return self;
}

# pragma mark - Save Overrideable Methods
- (void) willSaveToServerInSession:(TPSessionService *) session {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
}

- (TPLocalSerializableModel *) didSaveToServerInSession:(TPSessionService *) session withResponse:(id) responseObject {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return nil;
}

- (BOOL) isFirstTimeSave {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return NO;
}

- (NSString *) localSaveFilePath {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return nil;
}

- (NSString *) saveToUrlInSession:(TPSessionService *) session {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return nil;
}

- (NSString *) updateUrlInSession:(TPSessionService *) session {
  [NSException raise:@"TPLocalSerializableModel is a abstract base class, do not instantiate directly" format:@""];
  return nil;
}


- (BOOL) saveWithErrorDescription:(NSError **) error {
  return [self saveWithErrorDescription:error queueForUpdate:YES];
}

- (BOOL) saveWithErrorDescription:(NSError **) error queueForUpdate:(BOOL) queueForUpdate {
  NSString *filePath = [self localSaveFilePath];
  
  BOOL saved = [NSKeyedArchiver archiveRootObject:self toFile:filePath];
  if (saved && queueForUpdate) {
    // Queue it up for synchronization back to server
    TPBackgroundNetworkOperationQueue *queue = [TPBackgroundNetworkOperationQueue sharedInstance];
    TPBackgroundNetworkOperation *operation = [[TPBackgroundNetworkOperation alloc] initWithModel:self
                                                                                    operationType:TPSaveOperation
                                                                               duplicationAllowed:NO];
    
    [queue addOperation:operation tryFlushing:YES];
  }
  if (!saved) {
    if (NULL != error) {
      *error = [NSError errorWithDomain:kTPLocalOperationsDomain
                                   code:kSaveToLocalStorageError
                               userInfo:@{}];
    }
  } else {
    self.updatedAt = [NSDate date];
  }
  return saved;
}

+ (TPLocalSerializableModel *) latestInSession:(TPSessionService *)session
                             persistedFilePath:(NSString *) filePath
                              afterCompareWith:(TPLocalSerializableModel *) comparedResult {
  
  TPLocalSerializableModel *localResult = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  if (localResult == nil) {
    return comparedResult;
  } else {
    TPLocalSerializableModel *result = nil;
    // localResult is later than comparedResult
    if ([localResult.updatedAt compare:comparedResult.updatedAt] == NSOrderedDescending) {
      // localResult is the freshest one.
      result = localResult;
    } else {
      // comparedResult is the freshest one
      result = comparedResult;
      // save the freshest to disk:
      [NSKeyedArchiver archiveRootObject:comparedResult toFile:filePath];
    }
    return result;
  }
}


#pragma mark - TPBackgroundNetworkOperationTasks

- (void) saveSuccess:(void (^)(MTLModel *model))success
             failure:(void (^)(NSError *error))failure {
  // This saves back to the server when the device is online.
  // Intended to be called from the background operation queue.
  
  TPSessionService *session = [TPSessionService sharedInstance];
  
  [self willSaveToServerInSession:session];
  
  NSDictionary *jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:self];
  if ([self isFirstTimeSave]) {
    // Object not created on the server yet
    NSString *requestUrl = [self saveToUrlInSession:session];
    @weakify(self);
    [session POST:requestUrl parameters:jsonDict success:^(NSURLSessionDataTask *task, id responseObject) {
      @strongify(self);
      TPLocalSerializableModel *model = [self didSaveToServerInSession:session withResponse:responseObject];
      NSError *error;
      [model saveWithErrorDescription:&error queueForUpdate:NO];
      success(model);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      failure(error);
    }];
  } else {
    // Object exists on the server
    NSString *requestUrl = [self updateUrlInSession:session];
    @weakify(self);
    [session PUT:requestUrl parameters:jsonDict success:^(NSURLSessionDataTask *task, id responseObject) {
      @strongify(self);
      TPLocalSerializableModel *model = [self didSaveToServerInSession:session withResponse:responseObject];
      NSError *error;
      [model saveWithErrorDescription:&error queueForUpdate:NO];
      success(model);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      failure(error);
    }];
  }
}

//- (void) readWithParams:(NSDictionary *) params
//                success:(void (^)(MTLModel *model))success
//                failure:(void (^)(NSError *error))failure {
//  
//  TPSessionService *session = [TPSessionService sharedInstance];
//  
//  NSDictionary *fullParams = [self willReadFromServerInSession:session withParams:params];
//
//  NSString *requestUrl = [self readFromUrlInSession:session];
//  
//  [session GET:requestUrl parameters:fullParams success:^(NSURLSessionDataTask *task, id responseObject) {
//    TPLocalSerializableModel *model = [self didReadFromServerInSession:session withResponse:responseObject];
//    NSError *error;
//    [model saveWithErrorDescription:&error queueForUpdate:NO];
//    success(model);
//  } failure:^(NSURLSessionDataTask *task, NSError *error) {
//    failure(error);
//  }];
//}

@end
