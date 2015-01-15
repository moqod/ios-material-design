//
//  UIView+MaterialDesign.m
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/14/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "UIView+MaterialDesign.h"

const CGFloat UIViewMaterialDesignTransitionDurationCoeff			= 0.65;

@implementation UIView (MaterialDesign)

#pragma mark - public methods

+ (void)mdInflateTransitionFromView:(UIView *)fromView toView:(UIView *)toView originalPoint:(CGPoint)originalPoint duration:(NSTimeInterval)duration completion:(void (^)(void))block {
	if (fromView.superview) {
		UIView *containerView = fromView.superview;
		CGPoint convertedPoint = [fromView convertPoint:originalPoint fromView:fromView];
		containerView.layer.masksToBounds = YES;
		[containerView mdAnimateAtPoint:convertedPoint backgroundColor:toView.backgroundColor duration:duration * UIViewMaterialDesignTransitionDurationCoeff inflating:YES zTopPosition:YES shapeLayer:nil completion:^{
			toView.alpha = 0.0;
			
			// TODO: transform property could be not identity
			toView.frame = fromView.frame;
			[containerView addSubview:toView];
			[fromView removeFromSuperview];
			
			NSTimeInterval animationDuration = (duration - duration * UIViewMaterialDesignTransitionDurationCoeff);
			[UIView animateWithDuration:animationDuration
							 animations:^{
								 toView.alpha = 1.0;
							 }
							 completion:^(BOOL finished) {
								 if (block) {
									 block();
								 }
							 }];
		}];
	} else {
		if (block) {
			block();
		}
	}
}

+ (void)mdDeflateTransitionFromView:(UIView *)fromView toView:(UIView *)toView originalPoint:(CGPoint)originalPoint duration:(NSTimeInterval)duration completion:(void (^)(void))block {
	if (fromView.superview) {
		// insert destination view
		UIView *containerView = fromView.superview;
		[containerView insertSubview:toView belowSubview:fromView];
		toView.frame = fromView.frame;
		
		// convert point into container view coordinate system
		CGPoint convertedPoint = [toView convertPoint:originalPoint fromView:fromView];
		
		// insert layer
		CAShapeLayer *layer = [toView mdShapeLayerForAnimationAtPoint:convertedPoint];
		layer.fillColor = fromView.backgroundColor.CGColor;
		[toView.layer addSublayer:layer];
		toView.layer.masksToBounds = YES;
		
		// hide fromView
		NSTimeInterval animationDuration = (duration - duration * UIViewMaterialDesignTransitionDurationCoeff);
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 fromView.alpha = 0.0;
						 }
						 completion:^(BOOL finished) {
							 // perform disappear animation
							 [toView mdAnimateAtPoint:convertedPoint backgroundColor:fromView.backgroundColor duration:duration * UIViewMaterialDesignTransitionDurationCoeff inflating:NO zTopPosition:YES shapeLayer:layer completion:^{
								 if (block) {
									 block();
								 }
							 }];
						 }];
	} else {
		if (block) {
			block();
		}
		
	}
}

- (void)mdInflateAnimatedFromPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block {
	[self mdAnimateAtPoint:point backgroundColor:backgroundColor duration:duration inflating:YES zTopPosition:NO shapeLayer:nil completion:block];
}

- (void)mdDeflateAnimatedToPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block {
	[self mdAnimateAtPoint:point backgroundColor:backgroundColor duration:duration inflating:NO zTopPosition:NO shapeLayer:nil completion:block];
}

#pragma mark - helpers

- (CGFloat)mdShapeDiameterForPoint:(CGPoint)point {
	CGPoint cornerPoints[] = { {0.0, 0.0}, {0.0, self.bounds.size.height}, {self.bounds.size.width, self.bounds.size.height}, {self.bounds.size.width, 0.0} };
	CGFloat radius = 0.0;
	for (int i = 0; i < sizeof(cornerPoints) / sizeof(CGPoint); i++) {
		CGPoint p = cornerPoints[i];
		CGFloat d = sqrt( pow(p.x - point.x, 2.0) + pow(p.y - point.y, 2.0) );
		if (d > radius) {
			radius = d;
		}
	}
	return radius * 2.0;
}

- (CAShapeLayer *)mdShapeLayerForAnimationAtPoint:(CGPoint)point {
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	CGFloat diameter = [self mdShapeDiameterForPoint:point];
	shapeLayer.frame = CGRectMake(floor(point.x - diameter * 0.5), floor(point.y - diameter * 0.5), diameter, diameter);
	shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, diameter, diameter)].CGPath;
	return shapeLayer;
}

- (CABasicAnimation *)shapeAnimationWithTimingFunction:(CAMediaTimingFunction *)timingFunction scale:(CGFloat)scale inflating:(BOOL)inflating {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	if (inflating) {
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
		animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
	} else {
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
		animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
	}
	animation.timingFunction = timingFunction;
	animation.removedOnCompletion = YES;
	return animation;
}

#pragma mark - animation

- (void)mdAnimateAtPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration inflating:(BOOL)inflating zTopPosition:(BOOL)zTopPosition shapeLayer:(CAShapeLayer *)shapeLayer completion:(void (^)(void))block {
	if (!shapeLayer) {
		// create layer
		shapeLayer = [self mdShapeLayerForAnimationAtPoint:point];
		self.layer.masksToBounds = YES;
		if (zTopPosition) {
			[self.layer addSublayer:shapeLayer];
		} else {
			[self.layer insertSublayer:shapeLayer atIndex:0];
		}
		
		if (!inflating) {
			shapeLayer.fillColor = self.backgroundColor.CGColor;
			self.backgroundColor = backgroundColor;
		} else {
			shapeLayer.fillColor = backgroundColor.CGColor;
		}
	}
	
	// animate
	CGFloat scale = 1.0 / shapeLayer.frame.size.width;
	NSString *timingFunctionName = kCAMediaTimingFunctionDefault; //inflating ? kCAMediaTimingFunctionDefault : kCAMediaTimingFunctionDefault;
	CABasicAnimation *animation = [self shapeAnimationWithTimingFunction:[CAMediaTimingFunction functionWithName:timingFunctionName] scale:scale inflating:inflating];
	animation.duration = duration;
	shapeLayer.transform = [animation.toValue CATransform3DValue];
	
	__block UIView *selfRef = self;
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		if (inflating) {
			selfRef.backgroundColor = backgroundColor;
		}
		[shapeLayer removeFromSuperlayer];
		if (block) {
			block();
		}
	}];
	[shapeLayer addAnimation:animation forKey:@"shapeBackgroundAnimation"];
	[CATransaction commit];
}

@end
