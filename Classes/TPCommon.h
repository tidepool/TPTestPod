//
//  TPCommon.h
//  Pods
//
//  Created by Kerem Karatal on 2/17/14.
//
//

typedef struct {
  NSUInteger offset;
  NSUInteger limit;
  NSUInteger total;
  NSUInteger nextOffset;
  NSUInteger nextLimit;
} TPPageInfo;

// Game Unique Names
static NSString * const kTPGameCodeBreaker = @"CodeBreaker";
static NSString * const kTPGameLockPicker = @"LockPicker";
static NSString * const kTPGameShootout = @"Shootout";
static NSString * const kTPGameCodeWord = @"CodeWord";

// Tidepool specific errors
static NSString * const kTPSessionErrorDomain = @"com.tidepool.SessionError";
static NSString * const kTPLocalOperationsDomain = @"com.tidepool.LocalOperations";

// Response json
static NSString * const kTPDataResponseKey = @"data";
static NSString * const kTPStatusResponseKey = @"status";

static NSString * const kAccessTokenService = @"accessTokenService";
static NSString * const kRefreshTokenService = @"refreshTokenService";
static NSString * const kAccessTokenExpiresAtService = @"accessTokenExpiresAtService";
static NSString * const kIsGuestService = @"isGuestService";
static NSString * const kCachedUserIdService = @"cachedUserIdService";
//static NSString * const kRetryGuestRegistrationService = @"retryGuestRegistrationService";

static NSString * const kKeyChainServiceName = @"Tidepool";

// API Endpoints
static NSString * const kTPUserUrlRoot = @"api/v2/users";
static NSString * const kTPOAuthUrlRoot = @"api/v2/oauth2/token";
static NSString * const kTPFriendsUrlRoot = @"api/v2/friends";
static NSString * const kTPLeadersUrlRoot = @"api/v2/leaders";
static NSString * const kTPMissionUrlRoot = @"api/v2/missions";
static NSString * const kTPGameResultsUrlRoot = @"api/v2/game_results";
static NSString * const kTPAggregateGameResultsUrlRoot = @"api/v2/games/GAMEUNIQUENAME/aggregate_results";
static NSString * const kTPAggregateMissionResultsUrlRoot = @"api/v2/missions/MISSIONUNIQUENAME/aggregate_results";
static NSString * const kTPProfilePhotosURLRoot = @"api/v2/profile_photos";
static NSString * const kTPAgentProgressUrlRoot = @"api/v2/game_progresses";

// Error Info
static NSString * const kTPOriginalErrorResponseBody = @"TPOriginalErrorResponseBody";
static NSString * const kTPUserFriendlyErrorMessage = @"TPUserFriendlyErrorMessage";
static NSString * const kTPFailureCode = @"TPFailureCode";

static const NSInteger kUnknownServerError = 9999;
static const NSInteger kUnknownServerResponse = 9000;
static const NSInteger kUnknownMustFixClientStateError = 8000;
static const NSInteger kUnauthorizedAccessError = 1000;
static const NSInteger kRecordNotFoundError = 1001;
static const NSInteger kDuplicateRegistrationError = 1005;
static const NSInteger kNoRefreshTokenOrRefreshTokenExpiredError = 1006;
static const NSInteger kServerIsNotReachable = 1007;
static const NSInteger kFacebookAuthenticationError = 5000;

static const NSInteger kSaveToLocalStorageError = 3000;