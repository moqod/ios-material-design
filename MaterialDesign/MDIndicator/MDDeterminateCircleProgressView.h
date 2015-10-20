//
//  MDDeterminateCircleProgressView.h
//  Animation
//
//  Created by Andrew Kopanev on 10/13/15.
//  Copyright © 2015 Octoberry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDDeterminateCircleProgressView : UIView

@property (nonatomic, readonly) CAShapeLayer        *circleLayer;

// Default is 1.5
@property (nonatomic, assign) NSTimeInterval        rotationCycleAnimationDuration;

// [0..1]
@property (nonatomic, assign) CGFloat               progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)finishWithCompletion:(id)completion;

// rotation animation
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;


@end
