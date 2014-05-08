//
//  TPCodeBreakerGameViewController.m
//  TidePoolTwo
//
//  Created by Mayank Sanganeria on 2/4/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import "TPCodebreakerGameViewController.h"
#import "TPCodebreakerStageViewController.h"
#import "TPCodebreakerResultViewController.h"

@interface TPCodebreakerGameViewController ()
@end

@implementation TPCodebreakerGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Custom initialization
    [self commonInit];
  }
  return self;
}

-(void)commonInit
{
  self.StageClass = [TPCodebreakerStageViewController class];
  self.ResultClass = [TPResultViewController class];
  [super commonInit];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)configureStage:(TPStageViewController *)stage forLevel:(int)level
{
  TPCodebreakerStageViewController *codebreakerStageVC = (TPCodebreakerStageViewController *)stage;
  
  int rows[16] = {2,3,3,4,4,4,4,5,5,5,5,6,6,7,7};
  int cols[16] = {2,2,3,3,3,4,4,4,4,5,5,5,5,5,5,5};
  codebreakerStageVC.numberOfCirclesRows = rows[level-1]; // max 7
  codebreakerStageVC.numberOfCirclesColumns = cols[level-1]; // max 5
  codebreakerStageVC.numberOfCorrectCircles = level + 1;
  
}

//-(TPGameResult *)finalGameResult
//{
//  TPGameResult *result = [TPGameResult gameResultWithGameName:@"" withBlock:^(TPGameResult *gameResult) {
//  }];
//  NSString *game = @"codebreaker";
//  result.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@bg-blur.jpg", game, game]];
////  result.gameNameLabel.text = [game uppercaseString];
//  result.totalScoreLabel.text = [NSString stringWithFormat:@"%i", self.score + self.bonusScore];
//  result.bonusScoreLabel.text = [NSString stringWithFormat:@"%i", self.bonusScore];
//  result.levelLabel.text = [NSString stringWithFormat:@"%i", self.level];
//  result.levelScoreLabel.text = [NSString stringWithFormat:@"%i", self.score];
//}

@end
