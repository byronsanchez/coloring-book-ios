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
#import <QuartzCore/QuartzCore.h>

#import "Colors.h"
#import "ColorViewController.h"
#import "UIButton+StringTagAdditions.h"

// Creates a color palette from which users can select a color with which to
// draw.
@interface ColorPalette : NSObject {
  
 @private
  
  // Stores the colors associated with the Palette. (String -> Integer)
  NSMutableDictionary *_mColors;
  // Stores a parallel set of ImageButtons for each color.
  // Tags must be the same here. (String -> UIButtons)
  NSMutableDictionary *_mIbColors;
  
  // Reference to the master view.
  __unsafe_unretained ColorViewController *_mContext;
  
  CGFloat _buttonSize;
  CGFloat _mStrokeSize;
  
  // The default color to highlight.
  UIColor *_defaultColor;
}

@property(nonatomic, strong) NSMutableDictionary *mColors;
@property(nonatomic, strong) NSMutableDictionary *mIbColors;
@property(nonatomic, assign) CGFloat buttonSize;


// Constructor that sets the necessary properties for Palette objects.
- (id)initWithContext:(ColorViewController *)colorViewController
               colors:(NSMutableDictionary *)colors;

// Calculates button size.
- (void)calculateButtonSize;

// Creates the ImageButtons for the palette. ColorGFX and the canvas MUST BE
// CREATED BEFORE THIS CAN BE CALLED.
- (void)createButtons;

// Adds buttons to the specified view.
- (void)addToView:(UIView *)view;

// Handles click events.
- (IBAction)onClick:(id)sender;

// Sets the static variable containing a string-key of the last selected color.
+ (void)setLastTag:(NSString *)lastTag;

// Gets the static variable containing a string-key of the last selected color.
+ (NSString *)getLastTag;

@end
