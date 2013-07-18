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
    _mIsThreadRunning = NO;
    
  }
  return self;
}

// Main initializer for the ViewController.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    _mIsThreadRunning = NO;
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
  
  // Initialize a handler for dismissing the splash screen. It can only be
  // dismissed after both the time limit has passed and after and upgrades
  // and installations are complete. DB upgrades/installations are done async,
  // so we need to wait for it to signal completion. This is best done on a
  // seperate thread.
  if (!_mIsThreadRunning) {
    _mIsThreadRunning = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void) {
      
      // Set the running total of the time elapsed.
      NSInteger waited = 0;
      
      // For backwards compatibility, we are using the navigation controller
      // instead of the modal presenter.
      while (waited < kSplashTime || _mContext.mDbNodeHelper.mIsUpgradeTaskInProgress){
        // Loop this thread until the upgrade task is completed and after five
        // seconds have passed.
        [NSThread sleepForTimeInterval:1];
        // Add to the running total of the time elapsed.
        waited += 1000;
      }
      [self performSelectorOnMainThread:@selector(hideSplash) withObject:nil waitUntilDone:YES];
    });
  }
}

- (void)hideSplash {
  /*
  self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self dismissModalViewControllerAnimated:NO];*/
  [_mContext loadMusic];
  [self.navigationController popViewControllerAnimated:NO];

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
