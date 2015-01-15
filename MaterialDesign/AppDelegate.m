//
//  AppDelegate.m
//  MaterialDesign
//
//  Created by Andrew Kopanev on 1/14/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "AppDelegate.h"
#import "MDViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = [MDViewController new];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
