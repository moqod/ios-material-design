//
//  UIView+MaterialDesign.h
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/14/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MaterialDesign)

/**
 These methods animate background color of a view using shape animation.
 */
- (void)mdInflateAnimatedFromPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block;
- (void)mdDeflateAnimatedToPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block;

/**
 Some notes:
 - original point in fromView coordinate system
 - transition uses fromView.superview as containerView
 - transition set toView frame equal to fromView frame
 - transtion uses duration * 0.65 for shape transition and (duration - duration * 0.65) for fade animation, change it if you want
 */
+ (void)mdInflateTransitionFromView:(UIView *)fromView
							 toView:(UIView *)toView
					  originalPoint:(CGPoint)originalPoint
						   duration:(NSTimeInterval)duration
						 completion:(void (^)(void))block;

+ (void)mdDeflateTransitionFromView:(UIView *)fromView
							 toView:(UIView *)toView
					  originalPoint:(CGPoint)originalPoint
						   duration:(NSTimeInterval)duration
						 completion:(void (^)(void))block;

@end
