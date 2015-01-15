//
//  MDViewTwo.m
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/15/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "MDViewTwo.h"

@implementation MDViewTwo

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:94.0 / 255.0 green:125.0 / 255.0 blue:138.0 / 255.0 alpha:1.0];
		
		_backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.backButton setTitle:@"Back Button" forState:UIControlStateNormal];
		[self addSubview:self.backButton];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
		label.numberOfLines = 0;
		label.textAlignment = NSTextAlignmentCenter;
		label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		label.text = @"Imagine that it is some details view.";
		[self addSubview:label];
	}
	return self;
}

#pragma mark - layout

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat margin = 5.0;
	CGFloat buttonHeight = 100.0;
	self.backButton.frame = CGRectMake(margin, 0.0, self.bounds.size.width - margin * 2.0, buttonHeight);
}

@end
