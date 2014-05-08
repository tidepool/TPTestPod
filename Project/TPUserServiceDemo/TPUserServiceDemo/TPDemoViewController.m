//
//  TPDemoViewController.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 2/7/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import "TPDemoViewController.h"
#import <TPServices/TPSessionService.h>

@interface TPDemoViewController ()

- (IBAction) launchLoginView:(id) sender;
@end

@implementation TPDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) launchLoginView:(id)sender {
  TPSessionViewController *sessionViewController = [[TPSessionViewController alloc] initWithNibName:nil bundle:nil];
  sessionViewController.delegate = self;
  [self presentViewController:sessionViewController animated:YES completion:^{
    
  }];
}

- (void) userLoggedIn:(TPUser *)user {
  NSLog(@"User %@ logged in", user.email);
}
@end
