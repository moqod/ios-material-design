//
//  MDView.m
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/15/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "MDViewOne.h"
#import "UIView+MaterialDesign.h"

const NSTimeInterval MDViewOneAnimationDuration		= 0.5;

@interface MDViewOne ()

@property (nonatomic, readonly) UIView			*subview;
@property (nonatomic, readonly) UISwitch		*subviewSwitch;
@property (nonatomic, readonly) UIButton		*subviewButton;

@property (nonatomic, strong) NSMutableArray	*controls;

@end

@implementation MDViewOne

#pragma mark - helpers

- (CGFloat)randomNumber0_1 {
	return ( rand() % 10000 ) / 10000.0;
}

- (UIColor *)randomColor {
	return [UIColor colorWithRed:[self randomNumber0_1] green:[self randomNumber0_1] blue:[self randomNumber0_1] alpha:1.0];
}

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		srand( time(0) );
		
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		_subview = [UIView new];
		self.subview.backgroundColor = [UIColor colorWithRed:55.0 / 255.0 green:64.0 / 255.0 blue:69.0 / 255.0 alpha:1.0];
		[self addSubview:self.subview];
		
		UILabel *subviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
		subviewLabel.textAlignment = NSTextAlignmentCenter;
		subviewLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
		subviewLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		subviewLabel.numberOfLines = 0;
		subviewLabel.text = @"Hello, world!\nFew words label...";
		subviewLabel.textColor = [UIColor whiteColor];
		[self.subview addSubview:subviewLabel];
		
		_subviewSwitch = [UISwitch new];
		[self.subviewSwitch addTarget:self action:@selector(subviewSwitchAction:) forControlEvents:UIControlEventValueChanged];
		[self.subview addSubview:self.subviewSwitch];
		
		_subviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.subviewButton addTarget:self action:@selector(buttonAction:event:) forControlEvents:UIControlEventTouchUpInside];
		[self.subviewButton setTitle:@"Button" forState:UIControlStateNormal];
		[self.subview addSubview:self.subviewButton];
		
		self.controls = [NSMutableArray new];
		const NSInteger controlsCount = 4.0;
		for (NSInteger i = 0; i < controlsCount; i++) {
			UIControl *control = [UIControl new];
			control.backgroundColor = [self randomColor];
			[control addTarget:self action:@selector(controlAction:event:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:control];
			[self.controls addObject:control];
		}
		
		_detailsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.detailsButton setTitle:@"Show Details" forState:UIControlStateNormal];
		[self addSubview:self.detailsButton];
	}
	return self;
}

#pragma mark - actions

- (void)buttonAction:(UIControl *)sender event:(UIEvent *)event {
	CGPoint position = [[[event allTouches] anyObject] locationInView:self.subview];
	[self.subview mdInflateAnimatedFromPoint:position backgroundColor:[self randomColor] duration:MDViewOneAnimationDuration completion:nil];
}

- (void)controlAction:(UIControl *)sender event:(UIEvent *)event {
	CGPoint position = [[[event allTouches] anyObject] locationInView:sender];
	
	NSInteger index = [self.controls indexOfObjectIdenticalTo:sender];
	if (index % 2) {
		[sender mdInflateAnimatedFromPoint:position backgroundColor:[self randomColor] duration:MDViewOneAnimationDuration completion:nil];
	} else {
		[sender mdDeflateAnimatedToPoint:position backgroundColor:[self randomColor] duration:MDViewOneAnimationDuration completion:nil];
	}
}

- (void)subviewSwitchAction:(UISwitch *)swtch {
	if (swtch.isOn) {
		[self.subview mdInflateAnimatedFromPoint:swtch.center backgroundColor:[UIColor colorWithRed:0.0 / 255.0 green:150.0 / 255.0 blue:137.0 / 255.0 alpha:1.0] duration:MDViewOneAnimationDuration completion:nil];
	} else {
		[self.subview mdDeflateAnimatedToPoint:swtch.center backgroundColor:[UIColor colorWithRed:55.0 / 255.0 green:64.0 / 255.0 blue:69.0 / 255.0 alpha:1.0] duration:MDViewOneAnimationDuration completion:nil];
	}
}

#pragma mark - layout

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat detailsButtonHeight = 50.0;
	CGFloat subviewHeight = 200.0;
	CGFloat margin = 5.0;
	CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height + margin;
	
	self.subview.frame = CGRectMake(margin, y, self.bounds.size.width - margin * 2.0, subviewHeight);
	self.subviewSwitch.frame = CGRectMake(self.subview.bounds.size.width - self.subviewSwitch.bounds.size.width - margin, margin, self.subviewSwitch.bounds.size.width, self.subviewSwitch.bounds.size.height);
	self.subviewButton.frame = CGRectMake(self.subview.bounds.size.width - 60.0 - margin, self.subview.bounds.size.height - margin - 30.0, 60.0, 30.0);
	
	y = CGRectGetMaxY(self.subview.frame) + margin;
	CGFloat controlsSpace = self.bounds.size.height - y - detailsButtonHeight;
	if (self.controls.count) {
		CGFloat controlHeight = (controlsSpace - margin * (self.controls.count - 1)) / self.controls.count;
		
		for (UIControl *control in self.controls) {
			control.frame = CGRectMake(margin, y, self.bounds.size.width - margin * 2.0, controlHeight);
			y = CGRectGetMaxY(control.frame) + margin;
		}
	}

	self.detailsButton.frame = CGRectMake(margin, self.bounds.size.height - detailsButtonHeight, self.bounds.size.width - margin * 0.5, detailsButtonHeight);
}

@end
