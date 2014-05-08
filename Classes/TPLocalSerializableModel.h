//
//  TPLocalSerializableModel.h
//  Pods
//
//  Created by Kerem Karatal on 4/16/14.
//
//

#import <Mantle/Mantle.h>
#import "TPBackgroundNetworkOperation.h"
#import "TPSessionService.h"

@protocol TPComparable <NSObject>
@end

@class TPLocalSerializableModel;

@interface TPLocalSerializableModel : MTLModel<MTLJSONSerializing, TPBackgroundNetworkOperationTasks, TPComparable>

@property(nonatomic, strong) NSDate *updatedAt;

- (BOOL) saveWithErrorDescription:(NSError **) error;
- (BOOL) saveWithErrorDescription:(NSError **) error queueForUpdate:(BOOL) queueForUpdate;

+ (TPLocalSerializableModel *) latestInSession:(TPSessionService *)session
                             persistedFilePath:(NSString *) filePath
                              afterCompareWith:(TPLocalSerializableModel *) comparedResult;

// Below need to be implemented in subclasses

- (void) willSaveToServerInSession:(TPSessionService *) session;
- (TPLocalSerializableModel *) didSaveToServerInSession:(TPSessionService *) session withResponse:(id) responseObject;
- (BOOL) isFirstTimeSave;
- (NSString *) localSaveFilePath;
- (NSString *) saveToUrlInSession:(TPSessionService *) session;
- (NSString *) updateUrlInSession:(TPSessionService *) session;
@end
