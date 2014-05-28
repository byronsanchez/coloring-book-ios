/***************************************************************************
 
 Copyright (c) 2012 David Keegan (http://davidkeegan.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 ***************************************************************************/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

NS_ENUM(NSUInteger, KGModalBackgroundDisplayStyle) {
  KGModalBackgroundDisplayStyleGradient,
  KGModalBackgroundDisplayStyleSolid
};

@interface KGModal : NSObject

// Determines if the modal should dismiss if the user taps outside of the modal view
// Defaults to YES
@property (nonatomic) BOOL tapOutsideToDismiss;

// Determins if the close button or tapping outside the modal should animate the dismissal
// Defaults to YES
@property (nonatomic) BOOL animateWhenDismissed;

// Determins if the close button is shown
// Defaults to YES
@property (nonatomic) BOOL showCloseButton;

// The background color of the modal window
// Defaults black with 0.5 opacity
@property (strong, nonatomic) UIColor *modalBackgroundColor;

// The background display style, can be a transparent radial gradient or a transparent black
// Defaults to gradient, this looks better but takes a bit more time to display on the retina iPad
@property (nonatomic) enum KGModalBackgroundDisplayStyle backgroundDisplayStyle;

// Determins if the modal should rotate when the device rotates
// Defaults to YES, only applies to iOS5
@property (nonatomic) BOOL shouldRotate;

// The shared instance of the modal
+ (id)sharedInstance;


// Set the content view to display in the modal and display with animations
- (void)showWithContentView:(UIView *)contentView;

// Set the content view to display in the modal and whether the modal should animate in
- (void)showWithContentView:(UIView *)contentView andAnimated:(BOOL)animated;

// Set the content view controller to display in the modal and display with animations
- (void)showWithContentViewController:(UIViewController *)contentViewController;

// Set the content view controller to display in the modal and whether the modal should animate in
- (void)showWithContentViewController:(UIViewController *)contentViewController andAnimated:(BOOL)animated;

// Hide the modal with animations
- (void)hide;

// Hide the modal with animations,
// run the completion after the modal is hidden
- (void)hideWithCompletionBlock:(void(^)())completion;

// Hide the modal and whether the modal should animate away
- (void)hideAnimated:(BOOL)animated;

// Hide the modal and whether the modal should animate away,
// run the completion after the modal is hidden
- (void)hideAnimated:(BOOL)animated withCompletionBlock:(void(^)())completion;

@end
