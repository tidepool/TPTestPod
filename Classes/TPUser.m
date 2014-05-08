//
//  TPUser.m
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import "TPUser.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "TPAgentProgress.h"
#import "NSError+TPServiceErrors.h"

static NSString * const kUniqueId = @"unique_id";
static NSString * const kGuest = @"guest";
static NSString * const kPrimaryAccount = @"primary_account";
static NSString * const kAccountId = @"account_id";
static NSString * const kCredentials = @"credentials";
static NSString * const kCredentialsConfirmation = @"credentials_confirmation";
static NSString * const kDisplayName = @"display_name";
static NSString * const kName = @"name";
static NSString * const kImage = @"image";
static NSString * const kEmail = @"email";
static NSString * const kGender = @"gender";
static NSString * const kDateOfBirth = @"date_of_birth";
static NSString * const kAge = @"age";
static NSString * const kEducation = @"education";
static NSString * const kHandedness = @"handedness";
static NSString * const kCity = @"city";
static NSString * const kState = @"state";
static NSString * const kCountry = @"country";
static NSString * const kLocale = @"locale";
static NSString * const kProfilePhoto = @"profile_photo_url";

@interface TPUser()
@end

@implementation TPUser

- (instancetype) initWithUserId:(NSString *) userId {
  self = [super init];
  if (self) {
    _userId = [userId copy];
//    _agentProgress = nil;
  }
  return self;
}

#pragma mark - User API Access

+ (NSString *) filePathForUserId:(NSString *) userId {
  NSString *filePath = [TPSettings filePathForFilename:@"user_info.plist" folderName:userId];
  return filePath;
}

+ (TPUser *) userWithDictionary:(NSDictionary *) dict {
  NSError *error = nil;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:dict error:&error];
  
  [user saveUserInfoLocally];
  return user;
}

+ (TPUser *) userWithUserId:(NSString *) userId {
  NSString *filePath = [self filePathForUserId:userId];
  TPUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  
  if (user == nil) {
    // Nothing saved yet, initialize
    user = [[TPUser alloc] initWithUserId:userId];
    user.guest = YES;
    [user saveUserInfoLocally];
  }
  return user;
}

- (BOOL) saveUserInfoLocally {
  NSString *filePath = [TPUser filePathForUserId:self.userId];
  BOOL saved = [NSKeyedArchiver archiveRootObject:self toFile:filePath];
  
  return saved;
}

+ (void) findLoggedInUserWithSuccess:(void (^)(TPUser *user)) success
                             failure:(void (^)(NSError *error)) failure {
  TPSessionService *session = [TPSessionService sharedInstance];
  if ([session isNotReachableCallFailure:failure]) {
    return;
  }
  
  [session GET:[session userURLRoot] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSDictionary *dict = [responseObject valueForKey:kTPDataResponseKey];
    NSError *error;
    TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:dict error:&error];
    [user saveUserInfoLocally];
    success(user);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    BOOL willResolveError = [session resolveUnauthorizedAccessError:error success:^(TPSessionService *session) {
      // Retry
      [self findLoggedInUserWithSuccess:success failure:failure];
    } failure:^(NSError *error) {
      failure(error);
    }];
    if (!willResolveError) {
      failure(error);
    }
  }];
}

- (void) updateWithSuccess:(void (^)(TPUser *user)) success
                   failure:(void (^)(NSError *error)) failure {
  TPSessionService *session = [TPSessionService sharedInstance];
  if ([session isNotReachableCallFailure:failure]) {
    return;
  }
  
  NSString *requestUrl = [NSString stringWithFormat:@"%@%@", [session userServiceBaseURL], kTPUserUrlRoot];
  NSDictionary *userDict = [MTLJSONAdapter JSONDictionaryFromModel:self];
  
  [session PUT:requestUrl parameters:userDict success:^(NSURLSessionDataTask *task, id responseObject) {
    NSDictionary *dict = [responseObject valueForKey:kTPDataResponseKey];
    NSError *error;
    session.user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:dict error:&error];
    [session.user saveUserInfoLocally];
    success(self);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    BOOL willResolveError = [session resolveUnauthorizedAccessError:error success:^(TPSessionService *session) {
      // Retry
      [self updateWithSuccess:success failure:failure];
    } failure:^(NSError *error) {
      failure(error);
    }];
    if (!willResolveError) {
      failure(error);
    }
  }];
}

- (void) uploadProfilePhoto:(NSData *) profilePhoto
                    success:(void (^) (TPUser *user)) success
                    failure:(void(^)(NSError *error)) failure {
  TPSessionService *session = [TPSessionService sharedInstance];
  if ([session isNotReachableCallFailure:failure]) {
    return;
  }

  NSInteger randomNum = arc4random() % 10000;
  NSString *imageFilename = [NSString stringWithFormat:@"%@_profile_photo_v%ld.jpg", self.userId, (long)randomNum];
  NSString *requestUrl = [NSString stringWithFormat:@"%@%@", [session userServiceBaseURL], kTPProfilePhotosURLRoot];
  [session POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:profilePhoto name:@"profile_photo" fileName:imageFilename mimeType:@"image/jpeg"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"Success: %@", responseObject);
    NSDictionary *dict = [responseObject valueForKey:kTPDataResponseKey];
    NSError *error;
    session.user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:dict error:&error];
    [session.user saveUserInfoLocally];
    success(self);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    BOOL willResolveError = [session resolveUnauthorizedAccessError:error success:^(TPSessionService *session) {
      // Retry
      [self uploadProfilePhoto:profilePhoto success:success failure:failure];
    } failure:^(NSError *error) {
      failure(error);
    }];
    if (!willResolveError) {
      failure(error);
    }
  }];
}


- (void) friendsWithPageInfo:(TPPageInfo) pageInfo
                     success:(void (^)(NSArray *friends, TPPageInfo pageInfo)) success
                     failure:(void (^)(NSError *error)) failure {
  
  TPSessionService *session = [TPSessionService sharedInstance];
  if ([session isNotReachableCallFailure:failure]) {
    return;
  }
  
  NSDictionary *pageDict = [TPSettings dictionaryFromPageInfo:pageInfo];
  [session GET:[self friendsURLRoot] parameters:pageDict
       success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *friends = [self friendsArrayFromArray:[responseObject valueForKey:kTPDataResponseKey]];
         TPPageInfo pageInfo = [TPSettings pageInfoFromDictionary:[responseObject valueForKey:kTPStatusResponseKey]];
         
         success(friends, pageInfo);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
         BOOL willResolveError = [session resolveUnauthorizedAccessError:error success:^(TPSessionService *session) {
           // Retry
           [self friendsWithPageInfo:pageInfo success:success failure:failure];
         } failure:^(NSError *error) {
           failure(error);
         }];
         if (!willResolveError) {
           failure(error);
         }
       }];
}

#pragma mark - User Info Serialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
          @"imageURL": kImage,
          @"userId": kUniqueId,
          @"primaryAccount": kPrimaryAccount,
          @"accountId": kAccountId,
          @"displayName": kDisplayName,
          @"dateOfBirth": kDateOfBirth,
          @"profilePhotoURL": kProfilePhoto
           };
}

+ (NSValueTransformer *) imageURLJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
    if (![str isKindOfClass:NSString.class] || str == nil) return nil;
    NSRange range = [str rangeOfString:@"http"];
    NSString *imageURL = nil;
    if (range.location == NSNotFound) {
      TPSessionService *session = [TPSessionService sharedInstance];
      imageURL = [NSString stringWithFormat:@"%@%@", [session imageBaseURL], str];
    } else {
      imageURL = str;
    }
    return [NSURL URLWithString:imageURL];
  } reverseBlock:^(NSURL *imageURL) {
    return [imageURL absoluteString];
  }];
}

+ (NSValueTransformer *) profilePhotoURLJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
    if (![str isKindOfClass:NSString.class] || str == nil) return nil;
    return [NSURL URLWithString:str];
  } reverseBlock:^(NSURL *imageURL) {
    return [imageURL absoluteString];
  }];
}


+ (NSValueTransformer *) dateOfBirthJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
    return [[TPSettings dateOnlyFormatter] dateFromString:str];
  } reverseBlock:^(NSDate *date) {
    return [[TPSettings dateOnlyFormatter] stringFromDate:date];
  }];
}


#pragma mark - Friends Array serialization

- (NSArray *) friendsArrayFromArray:(NSArray *) input {
  NSMutableArray *friends = [NSMutableArray array];
  
  [input enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *dict = (NSDictionary *) obj;
    NSError *error;
    TPUser *friendUser = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:dict error:&error];
    
    [friends addObject:friendUser];
  }];
  return friends;
}



- (NSString *) friendsURLRoot {
  return [NSString stringWithFormat:@"%@%@", [[TPSessionService sharedInstance] userServiceBaseURL], kTPFriendsUrlRoot];
}

#pragma mark - Formatted Values

- (NSString *) formattedDisplayName {
  NSString *formattedDisplayName = @"";
  if (self.displayName == nil || [self.displayName isEqualToString:@""]) {
    NSArray *emailComps = [self.email componentsSeparatedByString:@"@"];
    if (emailComps && ([emailComps count] == 2)) {
      formattedDisplayName = [emailComps objectAtIndex:0];
    }
  } else if (self.displayName) {
    formattedDisplayName = self.displayName;
  }
  
  return formattedDisplayName;
}

- (NSString *) formattedAge {
  NSString *formattedAge = nil;
  if (self.age == 0) {
    if (self.dateOfBirth != nil) {
      NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
      NSTimeInterval seconds = [today timeIntervalSinceDate:self.dateOfBirth];
      NSInteger years = seconds / (60*60*24*365);
      formattedAge = [NSString stringWithFormat:@"%lu", (unsigned long) years];
    } else {
      formattedAge = @"N/A";
    }
  } else {
    formattedAge = [NSString stringWithFormat:@"%lu", (unsigned long) self.age];
  }
  return formattedAge;
}

- (void) setAgeFromFormattedAge:(NSString *) formattedAge {
  if ([formattedAge isEqualToString:@"N/A"]) {
    self.age = 0;
  } else {
    self.age = [formattedAge integerValue];
  }
}

- (NSString *) formattedDateOfBirth {
  return [[TPUser displayFormatterForDateOfBirth] stringFromDate:self.dateOfBirth];
}

- (void) setDateOfBirthFromFormattedDateOfBirth:(NSString *) formattedDateOfBirth {
  self.dateOfBirth = [[TPUser displayFormatterForDateOfBirth] dateFromString:formattedDateOfBirth];
}

- (NSString *) formattedGenderForText {
  NSString *formattedGender = @"N/S";
  if ([self.gender isEqualToString:@"male"]) {
    formattedGender = @"M";
  } else if ([self.gender isEqualToString:@"female"]) {
    formattedGender = @"F";
  } else if ([self.gender isEqualToString:@""]) {
    formattedGender = @"N/S";
  }
  return formattedGender;
}

- (NSInteger) formattedGender {
  NSInteger formattedGender = 0;
  if ([self.gender isEqualToString:@"male"]) {
    formattedGender = 0;
  } else if ([self.gender isEqualToString:@"female"]) {
    formattedGender = 1;
  } else if ([self.gender isEqualToString:@""]) {
    formattedGender = 2;
  }
  return formattedGender;
}

- (void) setGenderFromFormattedGender:(NSInteger) formattedGender {
  switch (formattedGender) {
    case 0:
      self.gender = @"male";
      break;
    case 1:
      self.gender = @"female";
      break;
    case 2:
      self.gender = @"";
      break;
    default:
      break;
  }
}

- (NSString *) formattedLocation {
  NSMutableString *formattedLocation = [NSMutableString stringWithCapacity:100];
  if (self.city != nil && (![self.city isEqualToString:@""])) {
    [formattedLocation appendString:[NSString stringWithFormat:@"%@", self.city]];
  }
  if (self.state != nil && (![self.state isEqualToString:@""])) {
    if ([formattedLocation isEqualToString:@""]) {
      [formattedLocation appendString:[NSString stringWithFormat:@"%@", self.state]];
    } else {
      [formattedLocation appendString:[NSString stringWithFormat:@", %@", self.state]];
    }
  }
  if (self.country != nil && (![self.country isEqualToString:@""])) {
    if ([formattedLocation isEqualToString:@""]) {
      [formattedLocation appendString:[NSString stringWithFormat:@"%@", self.country]];
    } else {
      [formattedLocation appendString:[NSString stringWithFormat:@", %@", self.country]];
    }
  }
  
  return formattedLocation;
}

- (void) setFormattedLocation:(NSString *) formattedLocation {
  
}

+ (NSDateFormatter *) displayFormatterForDateOfBirth {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterLongStyle];
  [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
  
  return formatter;
}

#pragma mark - AgentProgress

//- (void) refreshAgentProgressWithSuccess:(void (^)(TPAgentProgress *agentProgress)) success
//                                 failure:(void (^)(NSError *error)) failure {
//  
//  [TPAgentProgress agentProgressForCurrentUserWithSuccess:^(TPAgentProgress *agentProgress) {
//    _agentProgress = agentProgress;
//    success(agentProgress);
//  } failure:^(NSError *error) {
//    failure(error);
//  }];
//}

//- (TPAgentProgress *) agentProgress {
//  return _agentProgress;
//}
@end
