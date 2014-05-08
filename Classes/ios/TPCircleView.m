//
//  TPCircleView.m
//  TidePoolTwo
//
//  Created by Mayank Sanganeria on 1/31/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import "TPCircleView.h"
#import "CGHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation TPCircleView
{
  CAShapeLayer *_circleLayer;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextClearRect(context, rect);
  CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
  CGContextFillRect(context, rect);
  CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
  if (!_circleLayer) {
    _circleLayer = [CAShapeLayer layer];
    CGPathRef path = [CGHelper newCirclePathAtPoint:center withRadius:fminf(self.bounds.size.width/2, self.bounds.size.height/2)];
    _circleLayer.path = path;
    CGPathRelease(path);
    _circleLayer.fillColor = [UIColor turqoiseColor].CGColor;
    [self.layer addSublayer:_circleLayer];
  }
}

-(void)setSelected:(BOOL)selected
{
  _selected = selected;
  if (selected) {
    _circleLayer.fillColor = [UIColor sunflowerColor].CGColor;
  } else {
    _circleLayer.fillColor = [UIColor turqoiseColor].CGColor;
  }
}

-(void)flipToShowSelection
{
  float time = .5;
  CALayer *layer = self.layer;
  [UIView animateWithDuration:time/4 animations:^{
    layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:time/4 animations:^{
      self.selected = YES;
      layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:time/4
                            delay:0.5
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
                       }
                       completion:^(BOOL finished) {
                         [UIView animateWithDuration:time/4 animations:^{
                           self.selected = NO;
                           layer.transform = CATransform3DIdentity;
                           
                         }];
                       }];
    }];
  }];
}

-(void)flip
{
  [UIView animateWithDuration:1.0 animations:^{
    CALayer *layer = self.layer;
    layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
  } completion:^(BOOL finished) {
  }];
}

-(void)buildInBounce
{
  float time = 0.2;
  self.transform = CGAffineTransformMakeScale(1, 1);
  CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  [animation setFromValue:[NSNumber numberWithFloat:0]];
  [animation setToValue:[NSNumber numberWithFloat:1]];
  [animation setDuration:time];
  [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :0.5 :0.9 :1.5]];
  [self.layer addAnimation:animation forKey:nil];
  animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  [animation setFromValue:[NSNumber numberWithFloat:0]];
  [animation setToValue:[NSNumber numberWithFloat:1]];
  [animation setDuration:time];
  [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :0.5 :0.9 :1.5]];
  [self.layer addAnimation:animation forKey:nil];
  
}

-(void)buildOutBounce
{
  [UIView animateWithDuration:0.3 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformScale(t, 0.2, 0.2);
    self.transform = t;
    self.alpha = 0.1;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
  }];
}

@end
