//
//  MDViewController.m
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/15/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "MDViewController.h"
#import "MDViewOne.h"
#import "MDViewTwo.h"

#import "UIView+MaterialDesign.h"

@interface MDViewController ()

@property (nonatomic, readonly) MDViewOne		*viewOne;
@property (nonatomic, readonly) MDViewTwo		*viewTwo;

@end

@implementation MDViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_viewOne = [[MDViewOne alloc] initWithFrame:self.view.bounds];
	[self.viewOne.detailsButton addTarget:self action:@selector(showDetailsAction:event:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.viewOne];
	
	_viewTwo = [MDViewTwo new];
	[self.viewTwo.backButton addTarget:self action:@selector(backAction:event:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - actions

- (void)showDetailsAction:(UIButton *)sender event:(UIEvent *)event {
	CGPoint exactTouchPosition = [[[event allTouches] anyObject] locationInView:self.viewOne];
	[UIView mdInflateTransitionFromView:self.viewOne toView:self.viewTwo originalPoint:exactTouchPosition duration:0.7 completion:nil];
}

- (void)backAction:(UIButton *)sender event:(UIEvent *)event {
	CGPoint exactTouchPosition = [[[event allTouches] anyObject] locationInView:self.viewTwo];
	// [UIView mdDeflateTransitionFromView:self.viewTwo toView:self.viewOne originalPoint:exactTouchPosition duration:0.4 completion:nil];
	[UIView mdInflateTransitionFromView:self.viewTwo toView:self.viewOne originalPoint:exactTouchPosition duration:0.7 completion:^{
		NSLog(@"completed!");
	}];
}

@end
