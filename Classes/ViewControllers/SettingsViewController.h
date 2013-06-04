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

#import "Colors.h"
#import "Preferences.h"
#import "MusicManager.h"
#import "CreditsViewController.h"
#import "ShopViewController.h"

// Outputs a list of user-configurable settings to affect the user experience of
// the application. Also provides buttons to access other parts of the
// application, such as the shop or to view production credits (this is placed
// here to prevent negative UX due to placing shop and credits somewhere where
// the user can always see them. The settings place might be a good candidate as
// it is not-interfering and consequently, more of an opt-in if you want to
// access the credits or the shop).
@interface SettingsViewController : UIViewController {
  
 @private
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  
  UIButton *_mButtonMusic;
  UIButton *_mButtonShop;
  UIButton *_mButtonCredits;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) UIButton *_mButtonMusic;

// Updates the text preview based on text configuration preferences.
- (void)updateView;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
