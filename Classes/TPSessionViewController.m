//
//  TPSessionViewController.m
//  Pods
//
//  Created by Kerem Karatal on 2/7/14.
//
//

#import "TPSessionViewController.h"
#import "TPSessionService.h"
#import "TPSettings.h"
#import "TPAgentProgress.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

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
static NSString * const kCity = @"city";
static NSString * const kState = @"state";
static NSString * const kCountry = @"country";
static NSString * const kLocale = @"locale";
static NSString * const kProfilePhoto = @"profile_photo_url";

@interface TPSessionViewController ()
@property(nonatomic, strong) IBOutlet UIButton *toggleLoginSignupButton;
@property(nonatomic, strong) IBOutlet UITextField *usernameInput;
@property(nonatomic, strong) IBOutlet UITextField *passwordInput;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *alternateOptionLabel;
@property(nonatomic, strong) IBOutlet UIButton *fbLoginButton;
@property(nonatomic, strong) IBOutlet UIButton *actionButton;
@property(unsafe_unretained, nonatomic) IBOutlet UIView *userInfoArea;
@property(nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) UITextField *activeTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *fbLoginMessageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *loginCredentialsView;
@property(nonatomic, assign) BOOL displayLoginUI;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *continueAsGuestButton;
@end

@implementation TPSessionViewController

#pragma mark - Initialization

- (id)initWithSessionViewState:(TPSessionViewState) sessionViewState {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.sessionViewState = sessionViewState;
    self.activeTextField = nil;
    self.displayLoginUI = YES;
    self.guestLoginOption = NO;
  }
  
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
    self.sessionViewState = TPSessionLoginView;
    self.activeTextField = nil;
    self.displayLoginUI = YES;
    self.guestLoginOption = NO;
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma mark - Setup Views

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [self setUpUIForUserInput];
  self.displayLoginUI = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (self.displayLoginUI) {
    self.loginCredentialsView.hidden = NO;
    self.toggleLoginSignupButton.hidden = NO;
    self.fbLoginMessageLabel.hidden = YES;
  } else {
    self.loginCredentialsView.hidden = YES;
    self.toggleLoginSignupButton.hidden = YES;
    self.fbLoginMessageLabel.hidden = NO;
  }
  [self registerForKeyboardNotifications];

}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterForKeyboardNotifications];
}

- (void) setUpUIForUserInput {
  NSAttributedString *emailAttrStr = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
  NSAttributedString *passwordAttrStr = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
  self.usernameInput.attributedPlaceholder = emailAttrStr;
  self.passwordInput.attributedPlaceholder = passwordAttrStr;
  [self.fbLoginButton.titleLabel setFont:[UIFont fontWithName:@"Karla-Bold" size:15]];
  [self.toggleLoginSignupButton.titleLabel setFont:[UIFont fontWithName:@"Karla-Bold" size:15]];
  [self.alternateOptionLabel setFont:[UIFont fontWithName:@"Karla-Bold" size:15]];
  
  [self setupGuestOption];
  @weakify(self);
  [RACObserve(self, sessionViewState) subscribeNext:^(NSNumber *state) {
    @strongify(self);
    switch ([state integerValue]) {
      case TPSessionLoginView:
        [self setupLoginView];
        break;
      case TPSessionSignupView:
        [self setupSignupView];
        break;
      default:
        break;
    }
  }];
  
  self.toggleLoginSignupButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
    @strongify(self);
    switch (self.sessionViewState) {
      case TPSessionSignupView:
        self.sessionViewState = TPSessionLoginView;
        break;
      case TPSessionLoginView:
        self.sessionViewState = TPSessionSignupView;
      default:
        break;
    }
    return [RACSignal empty];
  }];
  
  RACSignal *tapGesture = self.tapGestureRecognizer.rac_gestureSignal;
  [tapGesture subscribeNext:^(id x) {
    @strongify(self);
    [self.usernameInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
  }];
}

- (void) setupGuestOption {
  if (self.guestLoginOption) {
    self.continueAsGuestButton.hidden = NO;
    @weakify(self);
    self.continueAsGuestButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
      @strongify(self);
      [self.delegate sessionViewController:self continueAsGuest:YES];
      return [RACSignal empty];
    }];
  } else {
    self.continueAsGuestButton.hidden = YES;
  }
}

- (void) setupLoginView {
  [self.toggleLoginSignupButton setTitle:@"New here? Sign Up" forState:UIControlStateNormal];
  [self.actionButton setImage:[UIImage imageNamed:@"btn-login"] forState:UIControlStateNormal | UIControlStateDisabled];
  [self.fbLoginButton setTitle:@"Sign In with Facebook" forState:UIControlStateNormal];
  
  @weakify(self);
  RACSignal *enabledSignal = [RACSignal
                              combineLatest:@[self.usernameInput.rac_textSignal,
                                              self.passwordInput.rac_textSignal]
                              reduce:^(NSString *username, NSString *password) {
                                @strongify(self);
                                return @([self validateForUsername:username password:password]);
                              }];
  
  
  TPSessionService *sessionService = [TPSessionService sharedInstance];
  self.actionButton.rac_command = [[RACCommand alloc] initWithEnabled:enabledSignal signalBlock:^(id input) {
    [sessionService loginWithUsername:self.usernameInput.text
                             password:self.passwordInput.text
                              success:^(TPSessionService *session) {
                                [TPAgentProgress agentProgressFromServerSuccess:^(TPAgentProgress *agentProgress) {
                                  @strongify(self);
                                  [self.delegate sessionViewController:self
                                                          userLoggedIn:session.user
                                                     withAgentProgress:agentProgress];
                                } failure:^(NSError *error) {
                                  NSLog(@"Agent Progress loading failed.");
                                  @strongify(self);
                                  [self.delegate sessionViewController:self loginError:error];
                                }];
                              } failure:^(NSError *error) {
                                NSLog(@"Login failed");
                                @strongify(self);
                                [self.delegate sessionViewController:self loginError:error];
                              }];
    return [RACSignal empty];
  }];
  
  self.fbLoginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self);
    [self loginUsingFacebook];
    return [RACSignal empty];
  }];
  
}

- (void) setupSignupView {
  [self.toggleLoginSignupButton setTitle:@"Have an account? Sign In" forState:UIControlStateNormal];
  [self.actionButton setImage:[UIImage imageNamed:@"btn-signup"] forState:UIControlStateNormal | UIControlStateDisabled];
  [self.fbLoginButton setTitle:@"Sign Up With Facebook" forState:UIControlStateNormal];
  
  @weakify(self);
  RACSignal *enabledSignal = [RACSignal
                              combineLatest:@[self.usernameInput.rac_textSignal,
                                              self.passwordInput.rac_textSignal
                                              ]
                              reduce:^(NSString *username, NSString *password){
                                @strongify(self);
                                BOOL lengthsOk = [self validateForUsername:username password:password];
                                return @(lengthsOk);
                              }];
  
  TPSessionService *sessionService = [TPSessionService sharedInstance];
  self.actionButton.rac_command = [[RACCommand alloc] initWithEnabled:enabledSignal signalBlock:^(id input) {
    NSString *guestUserId = nil;
    BOOL isConvertingFromGuest = NO;
    if (sessionService.isGuest) {
      guestUserId = sessionService.cachedUserId;
      isConvertingFromGuest = YES;
    }
    [sessionService registerWithEmail:self.usernameInput.text
                             password:self.passwordInput.text
                     convertFromGuest:isConvertingFromGuest
                          guestUserId:guestUserId
                              success:^(TPSessionService *session) {
                                @strongify(self);
                                TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
                                [self.delegate sessionViewController:self
                                                        userLoggedIn:session.user
                                                   withAgentProgress:agentProgress];
                              } failure:^(NSError *error) {
                                NSLog(@"Registration Failed");
                                @strongify(self);
                                [self.delegate sessionViewController:self loginError:error];
                              }];
    
    return [RACSignal empty];
  }];
  
  self.fbLoginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    @strongify(self);
    [self registerUsingFacebook];
    return [RACSignal empty];
  }];
}

#pragma mark - Facebook Login

- (void) loginUsingFacebook {
  [self fbOpenSessionWithUI:YES isRegisterRequest:NO];
}

- (void) registerUsingFacebook {
  [self fbOpenSessionWithUI:YES isRegisterRequest:YES];
}

- (void) fbOpenSessionWithUI:(BOOL) allowLoginUI isRegisterRequest:(BOOL) isRegisterRequest {
  [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                     allowLoginUI:allowLoginUI
                                completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                  // Handler for session state changes
                                  // This method will be called EACH time the session state changes,
                                  // also for intermediate states and NOT just when the session open
                                  [self fbSessionStateChanged:session state:state error:error isRegisterRequest:isRegisterRequest];
                                }];
  
}

- (void) fbSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error isRegisterRequest:(BOOL) isRegisterRequest
{
  // If the session was opened successfully
  if (!error && state == FBSessionStateOpen){
    NSLog(@"Session opened");
    // Show the user the logged-in UI
    [self retrieveUserInfoFromFacebookSuccess:^(NSDictionary *authHash) {
      if (isRegisterRequest) {
        [self handleFacebookRegisterForUser:authHash];
      } else {
        [self handleFacebookLoginForUser:authHash];
      }
    } failure:^(NSError *error) {
      [self.delegate sessionViewController:self loginError:error];
    }];
    
    return;
  }
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    // If the session is closed
    NSLog(@"Session closed");
  }
  
  // Handle errors
  if (error){
    NSString *failureMessage;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
      NSLog(@"Facebook Error - User should be notified.");
      failureMessage = [FBErrorUtility userMessageForError:error];
      NSError *fbError = [NSError errorWithDomain:kTPSessionErrorDomain
                                              code:-101
                                          userInfo:@{kTPFailureCode: @(kFacebookAuthenticationError),
                                                      kTPUserFriendlyErrorMessage: failureMessage}];
      [self.delegate sessionViewController:self loginError:fbError];
    } else {
      if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        // If the user cancelled login, do nothing

        NSLog(@"Facebook Error - User cancelled login");

      } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
        // Handle session closures that happen outside of the app
        NSLog(@"Facebook Error - Session closed outside of app.");

        failureMessage = @"Your current session is no longer valid. Please log in again.";
        NSError *fbError = [NSError errorWithDomain:kTPSessionErrorDomain
                                               code:-101
                                           userInfo:@{kTPFailureCode: @(kFacebookAuthenticationError),
                                                      kTPUserFriendlyErrorMessage: failureMessage}];
        [self.delegate sessionViewController:self loginError:fbError];
      } else {
        // For simplicity, here we just show a generic message for all other errors
        // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors

        //Get more error information from the error
        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
        
        // Show the user an error message
        failureMessage = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
        NSError *fbError = [NSError errorWithDomain:kTPSessionErrorDomain
                                               code:-101
                                           userInfo:@{kTPFailureCode: @(kFacebookAuthenticationError),
                                                      kTPUserFriendlyErrorMessage: failureMessage}];
        [self.delegate sessionViewController:self loginError:fbError];
      }
    }
    // Clear this token
    [FBSession.activeSession closeAndClearTokenInformation];
  }
}


- (void) handleFacebookLoginForUser:(NSDictionary *) authHash {
  TPSessionService *sessionService = [TPSessionService sharedInstance];

  @weakify(self);
  [sessionService loginWithAuthHash:authHash success:^(TPSessionService *session) {
    [TPAgentProgress agentProgressFromServerSuccess:^(TPAgentProgress *agentProgress) {
      @strongify(self);
      [self.delegate sessionViewController:self
                              userLoggedIn:session.user
                         withAgentProgress:agentProgress];
    } failure:^(NSError *error) {
      NSLog(@"Agent Progress loading failed.");
      @strongify(self);
      [self.delegate sessionViewController:self loginError:error];
    }];
  } failure:^(NSError *error) {
    NSNumber *failureCode = [[error userInfo] objectForKey: kTPFailureCode];
    @strongify(self);
    if (failureCode && [failureCode integerValue] == kRecordNotFoundError) {
      [self handleFacebookRegisterForUser:authHash];
    } else {
      [self.delegate sessionViewController:self loginError:error];
      NSLog(@"Failure - Unknown Error");
    }
  }];
}

- (void) handleFacebookRegisterForUser:(NSDictionary *) authHash  {
  TPSessionService *sessionService = [TPSessionService sharedInstance];
  
  NSString *guestUserId = nil;
  BOOL isConvertingFromGuest = NO;
  if (sessionService.isGuest) {
    guestUserId = sessionService.cachedUserId;
    isConvertingFromGuest = YES;
  }
  @weakify(self);
  [sessionService registerWithAuthHash:authHash
                      convertFromGuest:isConvertingFromGuest
                           guestUserId:guestUserId
                               success:^(TPSessionService *session) {
   TPAgentProgress *agentProgress = [TPAgentProgress agentProgressFromLocalCopy];
   [self.delegate sessionViewController:self
                           userLoggedIn:session.user
                      withAgentProgress:agentProgress];
  } failure:^(NSError *error) {
    NSNumber *failureCode = [[error userInfo] objectForKey: kTPFailureCode];
    @strongify(self);
    if (failureCode && [failureCode integerValue] == kDuplicateRegistrationError) {
      NSLog(@"Failure - Duplicate Registration Error");
      [self.delegate sessionViewController:self loginError:error];
    } else {
      NSLog(@"Failure - Unknown Error");
      [self.delegate sessionViewController:self loginError:error];
    }
  }];
}

- (void) retrieveUserInfoFromFacebookSuccess:(void (^)(NSDictionary *authHash))success
                                     failure:(void (^)(NSError *error))failure {
  
  [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (!error) {
      // Success! Include your code to handle the results here
      NSLog(@"User Info: %@", result);
      NSDictionary *authHash = [self authHashFromGraphUser:result];
      success(authHash);
    } else {
      // An error occurred, we need to handle the error
      // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
      NSLog(@"Facebook Error %@", error.description);
      failure(error);
    }
  }];

}

// Facebook response:
//User Info: {
//  birthday = "01/01/1901";
//  email = "kkaratal@gmail.com";
//  "first_name" = Kerem;
//  gender = male;
//  id = 609740882;
//  "last_name" = Karatal;
//  link = "https://www.facebook.com/kkaratal";
//  locale = "en_US";
//  location =     {
//    id = 114952118516947;
//    name = "San Francisco, California";
//  };
//  name = "Kerem Karatal";
//  timezone = "-7";
//  "updated_time" = "2013-05-13T17:55:41+0000";
//  username = kkaratal;
//  verified = 1;
//}

// http://graph.facebook.com/609740882/picture?type=large

- (NSDictionary *) authHashFromGraphUser:(id<FBGraphUser>)user {
  NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
  NSString *fbImageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
  NSDictionary *locationInfo = [user objectForKey:@"location"];
  NSString *formattedLocation = @"";
  NSString *city = @"";
  NSString *state = @"";
  if (locationInfo != nil) {
    formattedLocation = [locationInfo objectForKey:@"name"];
    NSArray *cityAndState = [formattedLocation componentsSeparatedByString:@","];
    if (cityAndState != nil && [cityAndState count] == 2) {
      city = [cityAndState objectAtIndex:0];
      state = [cityAndState objectAtIndex:1];
    }
  }
  NSString *dateOfBirth = [self dateOfBirthFromFacebookResult:[user objectForKey:@"birthday"]];
  NSDictionary *userInfo = @{kPrimaryAccount: @"facebook",
                             kName: user.name,
                             kDateOfBirth: dateOfBirth,
                             kCity: city,
                             kState: state,
                             kEmail: [user objectForKey:@"email"],
                             kGender: [user objectForKey:@"gender"],
                             kLocale: [user objectForKey:@"locale"],
                             kAccountId: [user objectForKey:@"id"],
                             kCredentials: fbAccessToken,
                             kCredentialsConfirmation: fbAccessToken,
                             kImage: fbImageUrl
                             };
  
  
  return userInfo;
}

- (NSString *) dateOfBirthFromFacebookResult:(NSString *) facebookBirthday {
  if (facebookBirthday == nil || [facebookBirthday isEqualToString:@""]) {
    return nil;
  }
  NSDateFormatter *fbDateFormatter = [[NSDateFormatter alloc] init];
  [fbDateFormatter setDateStyle:NSDateFormatterShortStyle];
  [fbDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
  NSDate *dateOfBirth = [fbDateFormatter dateFromString:facebookBirthday];
  return [[TPSettings dateFormatter] stringFromDate:dateOfBirth];
}

#pragma mark - Keyboard Display

- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
  
}

- (void) unregisterForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}


- (void) keyboardWillShow:(NSNotification *) aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  [UIView animateWithDuration:0.2 animations:^{
    self.view.transform = CGAffineTransformMakeTranslation(0, -kbSize.height/2);
  }];
}

-  (void) keyboardWillBeHidden:(NSNotification *) aNotification {
  [UIView animateWithDuration:0.2 animations:^{
    self.view.transform = CGAffineTransformIdentity;
  }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  self.activeTextField = nil;
}

#pragma Validations

- (BOOL) validateForUsername:(NSString *)username password:(NSString *)password {
  return [username length] > 0 && [password length] >= 8;
}

@end
