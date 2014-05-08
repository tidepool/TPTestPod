//
//  TPGameCodeBreakerViewController.h
//  TidePoolTwo
//
//  Created by Mayank Sanganeria on 1/31/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPStageViewController.h"

/*
 TPCodebreakerStageViewController is the concrete class that determines how to display a stage and handle the required interactions for this stage.
 
 It's properties typically determine how hard the stage is and the TPCodebreakerGameViewController sets these parameters according the 'level' of the game. For codebreaker, it needs to set how many rows and columns there are and how many of them are required to be correct.
 */

@interface TPCodebreakerStageViewController : TPStageViewController

@property (nonatomic, assign) int numberOfCirclesRows;
@property (nonatomic, assign) int numberOfCirclesColumns;
@property (nonatomic, assign) int numberOfCorrectCircles;

@end
