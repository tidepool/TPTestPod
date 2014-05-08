//
//  TPCircleView.h
//  TidePoolTwo
//
//  Created by Mayank Sanganeria on 1/31/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDesignHelper.h"

@interface TPCircleView : UIView

@property (assign, nonatomic) BOOL selected;

-(void)flipToShowSelection;

-(void)buildInBounce;
-(void)buildOutBounce;

@end
