//
//  MDDeterminateCircleProgressView.m
//  Animation
//
//  Created by Andrew Kopanev on 10/13/15.
//  Copyright © 2015 Octoberry. All rights reserved.
//

#import "MDDeterminateCircleProgressView.h"
#import <objc/runtime.h>

@interface MDDeterminateCircleProgressView ()

@property (nonatomic, readonly) CGFloat     circleRadius;
@property (nonatomic, assign) CGFloat       startAngle;

@property (nonatomic, assign) BOOL          wasAnimating;

@property (nonatomic, copy) dispatch_block_t    completionBlock;

@end

@implementation MDDeterminateCircleProgressView

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.startAngle = M_PI_2 * 3.0;
        self.rotationCycleAnimationDuration = 1.5;
        
        _circleLayer = [CAShapeLayer layer];
        self.circleLayer.strokeColor = [UIColor blueColor].CGColor;
        self.circleLayer.fillColor = NULL;
        self.circleLayer.lineWidth = 2.0;
        self.circleLayer.lineCap = kCALineCapRound;
        self.circleLayer.lineJoin = kCALineJoinRound;
        self.circleLayer.strokeStart = self.circleLayer.strokeEnd = 0.0;
        self.circleLayer.path = [self circleLayerPath].CGPath;
        [self.layer addSublayer:self.circleLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat circleRadius = floor(self.circleRadius * 2.0);
    self.circleLayer.frame = CGRectMake(ceil(self.bounds.size.width * 0.5 - circleRadius*0.5), ceil(self.bounds.size.height * 0.5 - circleRadius*0.5), circleRadius, circleRadius);
    
    self.circleLayer.path = [self circleLayerPath].CGPath;
}

#pragma mark - helpers

- (CGFloat)circleRadius {
    return MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
}

- (UIBezierPath *)circleLayerPath {
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleRadius, self.circleRadius) radius:self.circleRadius startAngle:self.startAngle endAngle:(self.startAngle + M_PI * 2.0) clockwise:YES];
}

#pragma mark - public

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    _progress = MIN(1.0, MAX(0.0, progress));
    
    if (animated && self.window) {
        // setup animation
        CGFloat initialValue = self.circleLayer.strokeEnd;
        self.circleLayer.strokeEnd = self.progress;
    
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 0.1;
        animation.fromValue = @( initialValue );
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.toValue = @( self.progress );
        [self.circleLayer addAnimation:animation forKey:@"strokeEnd"];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.strokeEnd = self.progress;
        [CATransaction commit];
    }
}

- (void)finishWithCompletion:(id)completion {
    if (!self.window) {
        self.circleLayer.transform = CATransform3DIdentity;
        self.circleLayer.strokeStart = 0;
        self.circleLayer.strokeEnd = 1;
        _progress = 1;
        // call completion
        return;
    }
    CGFloat currentAngle = fmod([[self.circleLayer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue], M_PI * 2.0);
    
    NSTimeInterval rotationDuration = 1.0;
    NSTimeInterval strokeDuration = rotationDuration * 1.3;
    
    [self.circleLayer setValue:@(M_PI * 2.0) forKey:@"transform.rotation.z"];
    CABasicAnimation *currentRotationAnimation = (CABasicAnimation *)[self.circleLayer animationForKey:@"transform.rotation.z"];
    
    // move circle to start angle
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @( currentAngle );
    rotateAnimation.toValue = @(M_PI * 2.0);
    rotateAnimation.duration = self.rotationCycleAnimationDuration;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotateAnimation.repeatCount = 1;
    rotateAnimation.speed = currentRotationAnimation.speed;
    rotateAnimation.duration = rotationDuration;
    rotateAnimation.delegate = self;
    [self.circleLayer addAnimation:rotateAnimation forKey:@"transform.rotation.z"];
    
    // set stroke to 1.0
    self.circleLayer.strokeEnd = 1.0;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = strokeDuration;
    animation.fromValue = @( self.progress );
    animation.toValue = @( 1.0 );
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleLayer addAnimation:animation forKey:@"strokeEnd"];
    
    _progress = 1.0;
    
    // call completion
}

#pragma mark - animation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.completionBlock) {
        
    }
}

- (void)startRotationAnimation {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @0;
    rotateAnimation.toValue = @(M_PI * 2.0);
    rotateAnimation.duration = self.rotationCycleAnimationDuration;
    rotateAnimation.repeatCount = HUGE_VALF;
    [self.circleLayer addAnimation:rotateAnimation forKey:@"transform.rotation.z"];
}

#pragma mark - public

- (void)startAnimating {
    if (![self isAnimating]) {
        self.wasAnimating = YES;
        [self startRotationAnimation];
    }
}

- (void)stopAnimating {
    if ([self isAnimating]) {
        self.wasAnimating = NO;
        [self innerStopAnimating];
    }
}

- (void)didMoveToWindow {
    if (self.wasAnimating) {
        if (self.window) {
            [self startRotationAnimation];
        } else {
            [self innerStopAnimating];
        }
    }
}

- (void)innerStopAnimating {
    [self.circleLayer removeAnimationForKey:@"transform.rotation.z"];
}

- (BOOL)isAnimating {
    return self.wasAnimating;
}

#pragma mark - notifications

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self innerStopAnimating];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if (self.wasAnimating) {
        [self startRotationAnimation];
    }
}

@end
