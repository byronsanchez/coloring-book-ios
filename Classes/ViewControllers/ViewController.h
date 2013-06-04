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
#import <Foundation/Foundation.h>

#import "SplashScreenViewController.h"
#import "SettingsViewController.h"
#import "KGModal.h"
#import "Preferences.h"
#import "Categorie.h"
#import "NodeDatabase.h"
#import "MusicManager.h"
#import "ViewPager.h"
#import "Toast+UIView.h"
#import "Colors.h"
#import "ColorViewController.h"

// Displays the default menu screen.
@interface ViewController : UIViewController<UIScrollViewDelegate>  {
  
 @private
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  
  // Define a category object that will store the category data from the
  // database.
  NSArray *_mCategoryData;
  
  // Declare a variable to store the current item id.
  NSInteger _mCurrentItemId;
  // Number of coloring books/categories available.
  NSInteger _mCategoryLength;
  
  // Cached calculated values so we don't have to regenerate them if they are
  // needed again.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  
  CGFloat _mPagerWidth;
  
  // floor width and height
  CGFloat _floorWidth;
  CGFloat _floorHeight;
  CGFloat _titleHeight;
  
  // Define views.
  UIButton *_mIbMainSettings;
  UIButton *_mIbMainHelp;
  UIButton *_mIbPagerLeft;
  UIButton *_mIbPagerRight;
  UIWebView *_infoView;
  CGFloat _webViewFontSize;
  
  // ViewPager properties
  UIScrollView *_mScrollView;
  NSMutableArray *_viewList;
  
  // To be used when scrolls originate from the UIPageControl
  BOOL _pageControlUsed;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) IBOutlet UIButton *mIbMainSettings;
@property(nonatomic, strong) IBOutlet UIButton *mIbMainHelp;
@property(nonatomic, strong) IBOutlet UIButton *mIbPagerLeft;
@property(nonatomic, strong) IBOutlet UIButton *mIbPagerRight;
@property(nonatomic, strong) IBOutlet UIScrollView *mScrollView;
@property(nonatomic, strong) NSMutableArray *viewList;


// Initialize the fragments to be paged.
- (void)initializePaging;

// Initializes the button displays based on the currentItemId.
- (void)updateButtons;

// Loads music if it is on.
- (void)loadMusic;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
