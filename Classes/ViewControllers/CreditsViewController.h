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

// Displays an animated activity screen with scrolling credits.
@interface CreditsViewController : UIViewController {
  
 @private
  
  // Define views.
  UIScrollView *_mSvCreditsBody;
  
  // Define display metric properties
  CGFloat _mScreenWidth;
  CGFloat _mScreenHeight;
  BOOL _isPortrait;
  
  // Define scroll animation properties.
  CGFloat _mVerticalScrollMax;
  CGFloat _mVerticalScrollMin;
  NSTimer *_mScrollTimer;
  CGFloat _mScrollPos;
  
  // Use for solo bitmap.
  UIImage *_image;
  
  // Define the credits display arrays.
  NSMutableArray *_mImageNameArray;
  
  // Device type.
  BOOL _isTablet;
  BOOL _isLarge;
}

@property(nonatomic, strong) IBOutlet UIScrollView *mSvCreditsBody;
@property(nonatomic, assign) CGFloat mScreenWidth;
@property(nonatomic, assign) CGFloat mScreenHeight;
@property(nonatomic, assign) BOOL isPortrait;
@property(nonatomic, assign) CGFloat mVerticalScrollMax;
@property(nonatomic, assign) CGFloat mVerticalScrollMin;
@property(nonatomic, strong) IBOutlet NSTimer *mScrollTimer;
@property(nonatomic, assign) CGFloat mScrollPos;
@property(nonatomic, strong) IBOutlet UIImage *image;
@property(nonatomic, strong) NSMutableArray *mImageNameArray;


// Adds images to the view. This is extendible to multiple images, but we
// are currently only using one very large credits image.
- (void)addImagesToView;

// Calculates and sets the maximum scroll value.
- (void)getScrollMaxAmount;

// Initiates the scrolling animation using a Timer.
- (void)startAutoScrolling;

// Moves the scroll view. This is called by the Timer Tick.
- (void)moveScrollView:(NSTimer *)theTimer;

// GCs the timer object.
- (void)clearTimers;

// Handles click events.
- (IBAction)onClick:(id)sender;

@end
