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

#import "NodeDatabase.h"
#import "Node.h"
#import "ColorGFX.h"


// Displays the currently selected image for coloring. Also displays color
// palettes, and coloring tools such as bucket, eraser, next image and previous
// image. Loops around if the bound of the currently selected category is
// reached.
@interface ColorViewController : UIViewController<UIAlertViewDelegate> {
  
 @private
  
  // Screen metrics.
  CGFloat _screenWidth;
  CGFloat _screenHeight;
  
  // Define the database access property.
  NodeDatabase *_mDbNodeHelper;
  
  // Define a category object that will store the category data from the
  // database.
  NSArray *_mNodeData;
  // Define a long number that we will receive from Main Activity when a user
  // selects a coloring book.
  NSInteger _mCid;
  
  // Define image properties.
  NSInteger _sCurrentImageId;
  NSInteger _mMinImageId;
  NSInteger _mMaxImageId;
  BOOL _isDirectionRight;
  
  // Layout views
  UIView *_mLlColorPaletteLeft;
  UIView *_mLlColorPaletteLeft2;
  UIView *_mLlColorPaletteRight;
  UIView *_mLlColorPaletteRight2;
  UIButton *_mIbLeft;
  UIButton *_mIbRight;
  UIButton *_mTbFillMode;
  UIButton *_mTbEraseMode;
  UIButton *_mIbReturn;
  
  // Define views.
  UIActivityIndicatorView *_mPbFloodFill;
  
  // The rendering engine.
  ColorGFX *_colorGFX;
  
  // Define a container for the palettes
  NSMutableDictionary *_hmPalette;
  
  // Current toggle button being used for the fill mode.
  NSString *_currentTbStatus;
}

@property(nonatomic, assign) NSInteger mCid;
@property(nonatomic, strong) ColorGFX *colorGFX;
@property(nonatomic, strong) UIActivityIndicatorView *mPbFloodFill;
@property(nonatomic, strong) NSMutableDictionary *hmPalette;


// Loads the brush and it's stylings.
- (void)loadBrushes;

// Sets up the coloring canvas. Loads the bitmap and draws it to the screen on
// the canvas.
- (void)loadColorCanvas;

// Sets up the color palettes.
- (void)loadColorPalettes;

// Sets the image to display on the canvas.
- (void)loadImage;

// Creates Image Buttons for each color defined in each palette.
- (void)loadPaletteButtons;

// Resizes the image if it is too big for the screen. This should almost
// never really be needed if the proper images are supplied to the drawable
// folders. However, in practice this may not be the case and therefore,
// this is used as a protection against these bad cases.
- (UIImage *)decodeImage:(NSString*)resId;

// Handles click events.
- (IBAction)onClick:(id)sender;

// Handles the return-to-menu process when the quit alert view dialog is
// confirmed.
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex;

// Accessor for static variable to check if the current device is a tablet.
+ (BOOL)getIsTablet;

// Accessor for static variable to check if the current device is large.
+ (BOOL)getIsLarge;

@end
