//
//  TPSessionViewController.h
//  Pods
//
//  Created by Kerem Karatal on 2/7/14.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TPUser.h"


typedef enum {
  TPSessionSignupView = 0,
  TPSessionLoginView = 1
} TPSessionViewState;

@class TPAgentProgress;
@class TPSessionViewController;
@protocol TPSessionViewEvents <NSObject>
@required
- (void) sessionViewController:(TPSessionViewController *) sessionVC
                  userLoggedIn:(TPUser *) user
             withAgentProgress:(TPAgentProgress *) agentProgress;
@optional
- (void) sessionViewController:(TPSessionViewController *) sessionVC loginError:(NSError *) error;
- (void) sessionViewController:(TPSessionViewController *) sessionVC continueAsGuest:(BOOL) continueAsGuest;
@end

@interface TPSessionViewController : UIViewController<FBLoginViewDelegate, UITextFieldDelegate>
@property(nonatomic) TPSessionViewState sessionViewState;
@property(nonatomic, weak) id<TPSessionViewEvents> delegate;
@property(nonatomic, assign) BOOL guestLoginOption;

- (id)initWithSessionViewState:(TPSessionViewState) sessionViewState; // Designated initializer
@end
