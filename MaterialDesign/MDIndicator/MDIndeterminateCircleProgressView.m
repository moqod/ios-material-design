//
//  MDIndeterminateCircleProgressView.m
//  Animation
//
//  Created by Andrew Kopanev on 10/12/15.
//  Copyright © 2015 Octoberry. All rights reserved.
//

#import "MDIndeterminateCircleProgressView.h"

@interface MDIndeterminateCircleProgressView ()

@property (nonatomic, assign) BOOL      wasAnimating;

@property (nonatomic, readonly) CGFloat     circleRadius;
@property (nonatomic, assign) CGFloat       startAngle;

@end

@implementation MDIndeterminateCircleProgressView

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.animationCycleDuration = 1.5;
        
        _circleLayer = [CAShapeLayer layer];
        self.circleLayer.strokeColor = [UIColor blueColor].CGColor;
        self.circleLayer.fillColor = NULL;
        self.circleLayer.lineWidth = 2.0;
        self.circleLayer.lineCap = kCALineCapRound;
        self.circleLayer.lineJoin = kCALineJoinRound;
        [self setupInitialStrokeValues];
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
    self.circleLayer.frame = CGRectMake(ceil(self.bounds.size.width * 0.5 - self.circleRadius), ceil(self.bounds.size.height * 0.5 - self.circleRadius), floor(self.circleRadius * 2.0), floor(self.circleRadius * 2.0));
}

#pragma mark - animation

#pragma mark * helpers

- (void)setupInitialStrokeValues {
    self.circleLayer.strokeStart = 0.0;
    self.circleLayer.strokeEnd = self.circleLayer.strokeStart + [self secondHalfStep];
}

- (CGFloat)firstHalfStep {
    return 0.8;
}

- (CGFloat)secondHalfStep {
    return 0.05;
}

- (NSTimeInterval)strokeAnimationHalfCycleDuration {
    return (self.animationCycleDuration - [self standingAnimationDuration]) * 0.5;
}

- (NSTimeInterval)standingAnimationDuration {
    return self.animationCycleDuration * 0.1;
}

- (NSTimeInterval)rotationAnimationDuration {
    return self.animationCycleDuration * 1.5;
}

- (CGFloat)circleRadius {
    return MIN(self.bounds.size.width, self.bounds.size.height) * 0.5;
}

- (UIBezierPath *)circleLayerPath {
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleRadius, self.circleRadius) radius:self.circleRadius startAngle:self.startAngle endAngle:(self.startAngle + M_PI * 2.0) clockwise:YES];
}

#pragma mark * core animation

- (void)startRotationAnimation {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @0;
    rotateAnimation.toValue = @(M_PI * 2.0);
    rotateAnimation.duration = [self rotationAnimationDuration];
    rotateAnimation.repeatCount = HUGE_VALF;
    [self.circleLayer addAnimation:rotateAnimation forKey:@"transform.rotation.z"];
}

- (void)startStrokeAnimation {
    CGFloat initialValue = self.circleLayer.strokeEnd;
    self.circleLayer.strokeEnd = [self firstHalfStep];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(initialValue);
    animation.toValue = @([self firstHalfStep]);
    animation.duration = [self strokeAnimationHalfCycleDuration];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.delegate = self;
    [self.circleLayer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
    
    if ([anim.keyPath isEqualToString:@"strokeEnd"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.beginTime = CACurrentMediaTime() + [self standingAnimationDuration];
        animation.fromValue = @0.0;
        animation.toValue = @( self.circleLayer.strokeEnd - [self secondHalfStep] );
        animation.duration = [self strokeAnimationHalfCycleDuration];
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.circleLayer addAnimation:animation forKey:@"strokeStart"];
    } else if ([anim.keyPath isEqualToString:@"strokeStart"]) {
        // disable implicit animations
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        // resetup start value
        self.circleLayer.strokeStart = [anim.toValue floatValue];
        [self.circleLayer removeAnimationForKey:@"strokeStart"];
        
        // setup new path
        self.startAngle = fmod((2.0 * M_PI * self.circleLayer.strokeStart) + self.startAngle, M_PI * 2.0);
        self.circleLayer.path = [self circleLayerPath].CGPath;
        [self setupInitialStrokeValues];
        
        [CATransaction commit];
        
        // launch again!
        [self startStrokeAnimation];
    }
}

#pragma mark - lifecycle

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

#pragma mark - public

- (void)startAnimating {
    if (![self isAnimating]) {
        self.wasAnimating = YES;
        [self innerStartAnimating];
    }
}

- (void)innerStartAnimating {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.circleLayer.opacity = 1.0;
    [CATransaction commit];
    
    // setup path
    self.circleLayer.path = [self circleLayerPath].CGPath;
    
    // add rotation animation
    [self startRotationAnimation];
    
    // launch stroke animation
    [self setupInitialStrokeValues];
    [self startStrokeAnimation];
}

- (void)stopAnimating {
    if ([self isAnimating]) {
        self.wasAnimating = NO;
        
        [self innerStopAnimating];
    }
}

- (void)innerStopAnimating {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.circleLayer.opacity = 0.0;
    [CATransaction commit];
    
    [self.circleLayer removeAllAnimations];
}

- (BOOL)isAnimating {
    return self.wasAnimating;
    // return [self.circleLayer animationForKey:@"transform.rotation.z"] != nil;
}

#pragma mark - notificaitons

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self innerStopAnimating];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if (self.wasAnimating) {
        [self innerStartAnimating];
    }
}

@end
