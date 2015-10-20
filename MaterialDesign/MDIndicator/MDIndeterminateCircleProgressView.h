//
//  MDIndeterminateCircleProgressView.h
//  Animation
//
//  Created by Andrew Kopanev on 10/12/15.
//  Copyright © 2015 Octoberry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIndeterminateCircleProgressView : UIView

// Default is 1.0
@property (nonatomic, assign) NSTimeInterval        animationCycleDuration;


@property (nonatomic, readonly) CAShapeLayer        *circleLayer;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
