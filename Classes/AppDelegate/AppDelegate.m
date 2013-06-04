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

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  
  // Ensure that the window is the proper screen size (3.5" vs. 4" for retina
  // screens to prevent bad layouts).
  self.window.frame = CGRectMake(0,
                                 0,
                                 [[UIScreen mainScreen] bounds].size.width,
                                 [[UIScreen mainScreen] bounds].size.height);
  
  // Hide the status bar for this application.
  [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
  
  // Implement standard xib file code.
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    _viewController = [[ViewController alloc]
                       initWithNibName:@"ViewController_iPad"
                                bundle:nil];
  }
  else {
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
      // iPhone 5+
      _viewController = [[ViewController alloc]
                         initWithNibName:@"ViewController_iPhoneLarge"
                                  bundle:nil];
    }
    else {
      // iPhone Classic
      _viewController = [[ViewController alloc]
                         initWithNibName:@"ViewController_iPhone"
                                  bundle:nil];
    }
  }
  
  _navController = [[UINavigationController alloc]
                    initWithRootViewController:_viewController];
  
  self.window.rootViewController = _navController;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

@end
