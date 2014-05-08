//
//  TPLeader.m
//  Pods
//
//  Created by Kerem Karatal on 4/11/14.
//
//

#import "TPLeader.h"
#import "TPSettings.h"
#import "TPSessionService.h"

static NSString * const kUserUniqueId = @"user_unique_id";
static NSString * const kProfilePhotoURL = @"profile_photo_url";
static NSString * const kUsername = @"username";
static NSString * const kScore = @"score";

static NSString * const kLeaderboardId = @"leaderboard_id";

@implementation TPLeader

+ (void) findByLeaderboardId:(NSString *) leaderboardId
                    pageInfo:(TPPageInfo) pageInfo
                     success:(void (^)(NSArray *leaders, TPPageInfo pageInfo))success
                     failure:(void (^)(NSError *error))failure {
  TPSessionService *session = [TPSessionService sharedInstance];
  if ([session isNotReachableCallFailure:failure]) {
    return;
  }
  
  NSMutableDictionary *pageDict = [NSMutableDictionary dictionaryWithDictionary:[TPSettings dictionaryFromPageInfo:pageInfo]];
  [pageDict setValue:leaderboardId forKey:kLeaderboardId];
  [session GET:[self leadersURLRoot] parameters:pageDict
       success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *friends = [self leadersArrayFromArray:[responseObject valueForKey:kTPDataResponseKey]];
         TPPageInfo pageInfo = [TPSettings pageInfoFromDictionary:[responseObject valueForKey:kTPStatusResponseKey]];
         
         success(friends, pageInfo);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
         BOOL willResolveError = [session resolveUnauthorizedAccessError:error success:^(TPSessionService *session) {
           // Retry
           [self findByLeaderboardId:leaderboardId pageInfo:pageInfo success:success failure:failure];
         } failure:^(NSError *error) {
           failure(error);
         }];
         if (!willResolveError) {
           failure(error);
         }
       }];
}


+ (NSString *) leadersURLRoot {
  return [NSString stringWithFormat:@"%@%@", [[TPSessionService sharedInstance] userServiceBaseURL], kTPLeadersUrlRoot];
}


+ (NSArray *) leadersArrayFromArray:(NSArray *) input {
  NSMutableArray *leaders = [NSMutableArray array];
  
  [input enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *dict = (NSDictionary *) obj;
    NSError *error;
    TPLeader *leader = [MTLJSONAdapter modelOfClass:TPLeader.class fromJSONDictionary:dict error:&error];
    
    [leaders addObject:leader];
  }];
  return leaders;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"name": kUsername,
           @"userId": kUserUniqueId,
           @"profilePhotoURL": kProfilePhotoURL
           };
}

+ (NSValueTransformer *) profilePhotoURLJSONTransformer {
  return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
    if (![str isKindOfClass:NSString.class] || str == nil) return nil;
    return [NSURL URLWithString:str];
  } reverseBlock:^(NSURL *imageURL) {
    return [imageURL absoluteString];
  }];
}

@end
