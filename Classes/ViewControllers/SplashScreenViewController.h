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

#import <UIKit/UIKit.h>

@class ViewController;

// Displays a Splash Screen on application launch.
@interface SplashScreenViewController : UIViewController {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  
  // Define views.
  UIImageView *_ivSplash;
  
  // Reference to the master view.
  __unsafe_unretained ViewController *_mContext;
}

@property(nonatomic, unsafe_unretained) ViewController *mContext;

// Dismisses the splash screen from the window.
- (void)hideSplash;

@end
