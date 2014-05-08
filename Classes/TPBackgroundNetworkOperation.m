//
//  TPBackgroundNetworkOperation.m
//  Pods
//
//  Created by Kerem Karatal on 4/4/14.
//
//

#import "TPBackgroundNetworkOperation.h"

@implementation TPBackgroundNetworkOperation

- (instancetype) initWithModel:(MTLModel<TPBackgroundNetworkOperationTasks> *) model
                 operationType:(TPBackgroundNetworkOperationType) operationType
            duplicationAllowed:(BOOL) duplicationAllowed {

  self = [super init];
  if (self) {
    [self initializeModel:model
                   params:[NSDictionary dictionary]
            operationType:operationType
       duplicationAllowed:duplicationAllowed];
  }
  return self;
}


- (instancetype) initWithModel:(MTLModel<TPBackgroundNetworkOperationTasks> *) model
                        params:(NSDictionary *) params
                 operationType:(TPBackgroundNetworkOperationType) operationType
            duplicationAllowed:(BOOL) duplicationAllowed {
  self = [super init];
  if (self) {
    [self initializeModel:model
                   params:params
            operationType:operationType
       duplicationAllowed:duplicationAllowed];
  }
  return self;
}

- (void) initializeModel:(MTLModel<TPBackgroundNetworkOperationTasks> *) model
                  params:(NSDictionary *) params
           operationType:(TPBackgroundNetworkOperationType) operationType
      duplicationAllowed:(BOOL) duplicationAllowed {
  _model = model;
  _name = NSStringFromClass(model.class);
  _operationType = operationType;
  _duplicationAllowed = duplicationAllowed;
  _params = params;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _name = [aDecoder decodeObjectForKey:@"name"];
    _model = [aDecoder decodeObjectForKey:@"model"];
    _operationType = [aDecoder decodeIntegerForKey:@"operationType"];
    _duplicationAllowed = [aDecoder decodeBoolForKey:@"duplicationAllowed"];
    _params = [aDecoder decodeObjectForKey:@"params"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.name forKey:@"name"];
  [aCoder encodeObject:self.model forKey:@"model"];
  [aCoder encodeInteger:self.operationType forKey:@"operationType"];
  [aCoder encodeBool:self.duplicationAllowed forKey:@"duplicationAllowed"];
  [aCoder encodeObject:self.params forKey:@"params"];
}

- (BOOL) isEqual:(id)object {
  TPBackgroundNetworkOperation *comparedOperation = object;
  return ([comparedOperation.name isEqualToString:self.name]);
}

@end
