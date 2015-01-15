# iOS Material Design Library

Inspired by [Material Design guideline](http://www.google.ru/design/spec/material-design/introduction.html) from Google.

![Image](https://raw.githubusercontent.com/moqod/ios-material-design/master/md.gif)

# Features
- Change background color with shape animation
- Perform transition animation between two views

# Sample
Clone the repo and run the project.

# Usage
Now there is only one interesting category `UIView+MaterialDesign`.
Instance methods:
``` objc
- (void)mdInflateAnimatedFromPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block;
- (void)mdDeflateAnimatedToPoint:(CGPoint)point backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration completion:(void (^)(void))block;
```
These methods allow you to change background color of a view using shape animation from any point, for example - touch, `UISwitch` or `UIControl` center.

Example for UIControl:
``` objc
- (void)buttonAction:(UIControl *)sender event:(UIEvent *)event {
	CGPoint position = [[[event allTouches] anyObject] locationInView:self.subview];
	[self.subview mdInflateAnimatedFromPoint:position backgroundColor:[self randomColor] duration:0.33 completion:nil];
}
```

<br />
Static methods:
``` objc
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
```

Example:
``` objc
- (void)showDetailsAction:(UIButton *)sender event:(UIEvent *)event {
	CGPoint exactTouchPosition = [[[event allTouches] anyObject] locationInView:self.viewOne];
	[UIView mdInflateTransitionFromView:self.viewOne toView:self.viewTwo originalPoint:exactTouchPosition duration:0.7 completion:nil];
}
```

These methods perform transition like `UIView` method:
``` objc
[UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionBeginFromCurrentState completion:nil];
```
but with shape animation from given point.

<br />
You could use this functinoality with any `UIView` instance without subclassing, cool, isnt'it?

<br />
Source code is simple, customize, use, add merge requests!

#Licence
MIT
