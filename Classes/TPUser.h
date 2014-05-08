//
//  TPUser.h
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "TPCommon.h"

//@class TPAgentProgress;

@interface TPUser : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy) NSString *userId;
@property(nonatomic) BOOL guest;
@property(nonatomic, copy) NSString *primaryAccount;
@property(nonatomic, copy) NSString *accountId;
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong, readonly) NSURL *imageURL;
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *gender;
@property(nonatomic, strong) NSDate *dateOfBirth;
@property(nonatomic) NSUInteger age;
@property(nonatomic, copy) NSString *education;
@property(nonatomic, copy) NSString *handedness;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *state;
@property(nonatomic, copy) NSString *country;
@property(nonatomic, copy) NSString *locale;
@property(nonatomic, strong, readonly) NSURL *profilePhotoURL;

+ (NSDateFormatter *) displayFormatterForDateOfBirth;

+ (TPUser *) userWithDictionary:(NSDictionary *) dict;
+ (TPUser *) userWithUserId:(NSString *) userId;

+ (void) findLoggedInUserWithSuccess:(void (^)(TPUser *user)) success
                             failure:(void (^)(NSError *error)) failure;

- (void) updateWithSuccess:(void (^)(TPUser *user)) success
                   failure:(void (^)(NSError *error)) failure;

- (void) friendsWithPageInfo:(TPPageInfo) pageInfo
                     success:(void (^)(NSArray *friends, TPPageInfo pageInfo)) success
                     failure:(void (^)(NSError *error)) failure;

- (void) uploadProfilePhoto:(NSData *) profilePhoto
                    success:(void (^) (TPUser *user)) success
                    failure:(void(^)(NSError *error)) failure;

- (BOOL) saveUserInfoLocally;

//- (void) refreshAgentProgressWithSuccess:(void (^)(TPAgentProgress *agentProgress)) success
//                                 failure:(void (^)(NSError *error)) failure;
//- (TPAgentProgress *) agentProgress;


- (NSString *) formattedDisplayName;
- (NSString *) formattedAge;
- (NSInteger) formattedGender;
- (NSString *) formattedGenderForText;
- (NSString *) formattedDateOfBirth;
- (NSString *) formattedLocation;
- (void) setGenderFromFormattedGender:(NSInteger) formattedGender;
- (void) setAgeFromFormattedAge:(NSString *) formattedAge;
- (void) setDateOfBirthFromFormattedDateOfBirth:(NSString *) formattedDateOfBirth;
- (void) setFormattedLocation:(NSString *) formattedLocation;
@end