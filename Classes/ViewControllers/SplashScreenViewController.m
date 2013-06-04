//
// Copyright (c) 2013 Byron Sanchez (hackbytes.com)
// www.chompix.com
//
// This file is part of "Coloring Book for iOS."
//
// "Coloring Book for iOS" is free software: you can redistribute
// it and/or modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation, version
// 2 of the License.
//
// "Coloring Book for iOS" is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with "Coloring Book for iOS."  If not, see
// <http://www.gnu.org/licenses/>.
//

#import "SplashScreenViewController.h"
#import "ViewController.h"

static NSInteger const kSplashTime = 5000; //

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

@synthesize mContext = _mContext;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

// Main initializer for the ViewController.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  /*
   * This screen needs to be dynamically positioned to fit each screen
   * size fluidly.
   */
  
  // Get the screen metrics.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  // Use inversed metrics since this application is landscape only.
  _screenWidth = screenRect.size.height;
  _screenHeight = screenRect.size.width;
  
  // SPLASH BACKGROUND
  
  UIImage *imageBackground = [UIImage imageNamed:@"bg"];
  UIImageView *backgroundView = [[UIImageView alloc] initWithImage:imageBackground];
  backgroundView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
  [backgroundView setContentMode:UIViewContentModeScaleAspectFill];
  
  [[self view] addSubview:backgroundView];
  
  
  // SPLASH IMAGE
  
  UIImage *splashImage = [UIImage imageNamed:@"logo"];
  _ivSplash = [[UIImageView alloc] initWithImage:splashImage];
  _ivSplash.frame = CGRectMake((_screenWidth / 2) - (splashImage.size.width / 2),
                               (_screenHeight / 2) - (splashImage.size.height / 2),
                               splashImage.size.width,
                               splashImage.size.height);
  [_ivSplash setContentMode:UIViewContentModeTopLeft];
  
  [[self view] addSubview:_ivSplash];
  
}

#pragma mark - UIViewController Methods

// Implements viewDidAppear.
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
  
	// Do something awesome
	[self performSelector:@selector(hideSplash)
             withObject:nil
             afterDelay:(kSplashTime / 1000.0)];
}

- (void)hideSplash {
  /*
  self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self dismissModalViewControllerAnimated:NO];*/
  
  // For backwards compatibility, we are using the navigation controller instead
  // of the modal presenter.
  [self.navigationController popViewControllerAnimated:NO];
  
  [_mContext loadMusic];
}

// Implements viewDidUnload.
- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

// Returns whether or not a UI orientation change should occur based on the
// current physical device orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
