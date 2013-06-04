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

#import "ColorViewController.h"
#import "ColorPalette.h"

// Static variable used by ColorPalette to determine size of views.
// ColorPalette doesn't need to know about Retina 3.5" vs. 4"
static BOOL sIsTablet;
static BOOL sIsLarge;

@interface ColorViewController ()

@end

@implementation ColorViewController

@synthesize mCid = _mCid;
@synthesize colorGFX = _colorGFX;
@synthesize mPbFloodFill = _mPbFloodFill;
@synthesize hmPalette = _hmPalette;

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
    
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  // Custom initialization
  _sCurrentImageId = 0;
  _isDirectionRight = YES;
  _currentTbStatus = @"";
  
  // Define a container for the palettes
  _hmPalette = [[NSMutableDictionary alloc] init];
  
  /*
   * This screen needs to be dynamically positioned to fit each screen
   * size fluidly.
   */
  
  // Get the screen metrics.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  
  // Use standard metrics. Autoresizing masks will take care of orientation
  // changes.
  _screenWidth = screenRect.size.height;
  _screenHeight = screenRect.size.width;
  
  // DETERMINE DEVICE TYPE
  NSInteger device = UI_USER_INTERFACE_IDIOM();
  
  // Set defaults
  sIsTablet = NO;
  sIsLarge = NO;
  
  switch (device) {
    case UIUserInterfaceIdiomPhone: {
      if (_screenHeight == 480) {
        
        // iPhone Classic
        sIsLarge = NO;
        
      }
      if (_screenHeight == 568) {
        sIsLarge = YES;
      }
    }
      break;
      
    case UIUserInterfaceIdiomPad: {
      sIsTablet = YES;
    }
      break;
  }
  
  // Set the view background color.
  [[self view] setBackgroundColor:[Colors colorFromHexString:@"#00163BFF"]];
  
  /**
   * Database check!
   */
  
  // Create our database access object.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  [_mDbNodeHelper createDatabase];
  
  // Query the database for a node containing the id which was passed
  // from BrowseActivity.
  _mNodeData = [_mDbNodeHelper getNodeListData:_mCid];
  _mMinImageId = 0;
  _mMaxImageId = ([_mNodeData count] - 1);
  
  // Close the database.
  [_mDbNodeHelper close];
  
  // Create the progressbar view
  if (sIsTablet) {
    _mPbFloodFill = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(2.8f, 2.8f);
    _mPbFloodFill.transform = transform;
  }
  else {
    _mPbFloodFill = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  }
  
  // Accessing color is not backwards compatible.
  //_mPbFloodFill.color = [UIColor blackColor];
  
  [_mPbFloodFill setHidden:YES];
  
  // Load the canvas.
  [self loadColorCanvas];
  
  // Load the color palettes.
  [self loadColorPalettes];
  
  // Create the palette buttons.
  [self loadPaletteButtons];
  
  // Load brushes
  [self loadBrushes];
  
}

- (void)loadBrushes {
  [_colorGFX setBrushStyles:_colorGFX.movePathCanvas];
  [_colorGFX setBrushStyles:_colorGFX.pathCanvas];
  
  /*
   _colorGFX.paint.setDither(true);
   mBlur = new BlurMaskFilter(8, BlurMaskFilter.Blur.NORMAL);
   _colorGFX.paint.setMaskFilter(mBlur);
   */
}

- (void)loadColorCanvas {
  // Load the first image in the currently selected coloring book.
  [self loadImage];
  
  // Add the canvas to the main screen.
  [_colorGFX setContentMode:UIViewContentModeScaleAspectFit];
  [_colorGFX setAutoresizingMask:UIViewAutoresizingNone];
  [_mPbFloodFill setContentMode:UIViewContentModeScaleAspectFit];
  [_mPbFloodFill setAutoresizingMask:UIViewAutoresizingNone];
  
  // Set padding for the return button and progress indicator.
  CGFloat pbPadding = 0;
  
  if (sIsTablet) {
    pbPadding = 10;
  }
  else {
    pbPadding = 4;
  }
  
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  
  // Return button.
  _mIbReturn = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbReturn addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [_mIbReturn setImage:returnButtonImage forState:UIControlStateNormal];
  [_mIbReturn setAlpha:0.5];
  _mIbReturn.frame = CGRectMake(pbPadding,
                                pbPadding,
                                returnButtonImage.size.width,
                                returnButtonImage.size.height);
  [_mIbReturn setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:13];
  
  // Configure the progress bar positioning (top right with padding).
  _mPbFloodFill.frame = CGRectMake((_colorGFX.frame.size.width - _mPbFloodFill.frame.size.width) - pbPadding,
                                   pbPadding,
                                   _mPbFloodFill.frame.size.width,
                                   _mPbFloodFill.frame.size.height);
  
  // Add the canvas to the main view.
  [[self view] addSubview:_colorGFX];
  // Add the return button and progress bar to the canvas view.
  [_colorGFX addSubview:_mIbReturn];
  [_colorGFX addSubview:_mPbFloodFill];
}

- (void)loadColorPalettes {
  /*
   * Pallete 1
   */
  
  // Create a tag and a HashMap of colors to assign to Palette1
  NSString *tag = @"Palette1";
  
  NSMutableDictionary *colors = [[NSMutableDictionary alloc] init];
  [colors setValue:[UIColor colorWithRed:255/255.0
                                   green:106/255.0
                                    blue:106/255.0
                                   alpha:1.0]
            forKey:@"1_lightRed"];
  [colors setValue:[UIColor colorWithRed:220/255.0
                                   green:20/255.0
                                    blue:60/255.0
                                   alpha:1.0]
            forKey:@"2_red"];
  [colors setValue:[UIColor colorWithRed:255/255.0
                                   green:140/255.0
                                    blue:0/255.0
                                   alpha:1.0]
            forKey:@"3_orange"];
  [colors setValue:[UIColor colorWithRed:255/255.0
                                   green:255/255.0
                                    blue:0/255.0
                                   alpha:1.0]
            forKey:@"4_yellow"];
  [colors setValue:[UIColor colorWithRed:255/255.0
                                   green:185/255.0
                                    blue:15/255.0
                                   alpha:1.0]
            forKey:@"5_gold"];
  
  // Create a new palette based on this information.
  ColorPalette *Palette1;
  Palette1 = [[ColorPalette alloc] initWithContext:self colors:colors];
  
  // Add the palette to the HashMap.
  [_hmPalette setValue:Palette1 forKey:tag];
  
  
  /*
   * Palette 2
   */
  
  // Create a tag and a HashMap of colors to assign to Palette1
  tag = @"Palette2";
  
  NSMutableDictionary *colors2 = [[NSMutableDictionary alloc] init];
  [colors2 setValue:[UIColor colorWithRed:0/255.0
                                    green:205/255.0
                                     blue:0/255.0
                                    alpha:1.0]
             forKey:@"1_green"];
  [colors2 setValue:[UIColor colorWithRed:0/255.0
                                    green:128/255.0
                                     blue:0/255.0
                                    alpha:1.0]
             forKey:@"2_darkGreen"];
  [colors2 setValue:[UIColor colorWithRed:99/255.0
                                    green:184/255.0
                                     blue:255/255.0
                                    alpha:1.0]
             forKey:@"3_lightBlue"];
  [colors2 setValue:[UIColor colorWithRed:0/255.0
                                    green:0/255.0
                                     blue:255/255.0
                                    alpha:1.0]
             forKey:@"4_blue"];
  [colors2 setValue:[UIColor colorWithRed:39/255.0
                                    green:64/255.0
                                     blue:139/255.0
                                    alpha:1.0]
             forKey:@"5_darkBlue"];
  
  // Create a new palette based on this information.
  ColorPalette *Palette2;
  Palette2 = [[ColorPalette alloc] initWithContext:self colors:colors2];
  
  // Add the palette to the HashMap.
  [_hmPalette setValue:Palette2 forKey:tag];
  
  /*
   * Palette 3
   */
  
  // Create a tag and a HashMap of colors to assign to Palette1
  tag = @"Palette3";
  
  NSMutableDictionary *colors3 = [[NSMutableDictionary alloc] init];
  [colors3 setValue:[UIColor colorWithRed:75/255.0
                                    green:0/255.0
                                     blue:130/255.0
                                    alpha:1.0]
             forKey:@"1_indigo"];
  [colors3 setValue:[UIColor colorWithRed:148/255.0
                                    green:0/255.0
                                     blue:211/255.0
                                    alpha:1.0]
             forKey:@"2_violet"];
  [colors3 setValue:[UIColor colorWithRed:255/255.0
                                    green:105/255.0
                                      blue:180/255.0
                                    alpha:1.0]
             forKey:@"3_pink"];
  [colors3 setValue:[UIColor colorWithRed:255/255.0
                                    green:215/255.0
                                     blue:164/255.0
                                    alpha:1.0]
             forKey:@"4_peach"];
  [colors3 setValue:[UIColor colorWithRed:205/255.0
                                    green:133/255.0
                                     blue:63/255.0
                                    alpha:1.0]
             forKey:@"5_lightBrown"];
  
  // Create a new palette based on this information.
  ColorPalette *Palette3;
  Palette3 = [[ColorPalette alloc] initWithContext:self colors:colors3];
  
  // Add the palette to the HashMap.
  [_hmPalette setValue:Palette3 forKey:tag];
  
  /*
   * Palette 4
   */
  
  // Create a tag and a HashMap of colors to assign to Palette1
  tag = @"Palette4";
  
  NSMutableDictionary *colors4 = [[NSMutableDictionary alloc] init];
  [colors4 setValue:[UIColor colorWithRed:0/255.0
                                    green:0/255.0
                                     blue:0/255.0
                                    alpha:1.0]
             forKey:@"1_black"];
  [colors4 setValue:[UIColor colorWithRed:128/255.0
                                     green:128/255.0
                                     blue:128/255.0
                                    alpha:1.0]
             forKey:@"2_grey"];
  [colors4 setValue:[UIColor colorWithRed:255/255.0
                                    green:255/255.0
                                     blue:255/255.0
                                    alpha:1.0]
             forKey:@"3_white"];
  [colors4 setValue:[UIColor colorWithRed:183/255.0
                                    green:183/255.0
                                     blue:183/255.0
                                    alpha:1.0]
             forKey:@"4_lightgrey"];
  [colors4 setValue:[UIColor colorWithRed:139/255.0
                                    green:69/255.0
                                     blue:19/255.0
                                    alpha:1.0]
             forKey:@"5_brown"];
  
  // Create a new palette based on this information.
  ColorPalette *Palette4;
  Palette4 = [[ColorPalette alloc] initWithContext:self colors:colors4];
  
  // Add the palette to the HashMap.
  [_hmPalette setValue:Palette4 forKey:tag];
  
}

- (void)loadPaletteButtons {
  
  /**
   * Calculate pallete metrics.
   */
  NSArray *buttonArray = [[_hmPalette allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  // Iterate through the palettes
  for (NSString *key in buttonArray) {
    // Load the button size.
    [[_hmPalette objectForKey:key] calculateButtonSize];
    // Get the palette object and create ImageButtons for the color set
    // that corresponds to that palette object.
    [[_hmPalette objectForKey:key] createButtons];
    // Add the palettes to a view.
  }
  
  // Calculate the size of all buttons in each palette using Palette 1 as the
  // template.
  ColorPalette *tempPalette = [_hmPalette objectForKey:@"Palette1"];
  CGFloat colorCount = [tempPalette.mColors count];
  CGFloat buttonSize = tempPalette.buttonSize;
  CGFloat totalPaletteHeight = colorCount * buttonSize;
  
  // Calculate positioning for color palette buttons
  CGFloat paletteWidth = buttonSize;
  
  /**
   * Calculate UIButton metrics.
   */
  
  // The total available space for buttons on one side of the screen.
  CGFloat buttonWidth = (_screenWidth - _colorGFX.bounds.size.width) / 2;
  // Store the color button size locally for the palette frame calculation.
  CGFloat colorButtonSize = ((ColorPalette *) [_hmPalette objectForKey:@"Palette1"]).buttonSize;
  
  UIImage *leftButtonImage = [UIImage imageNamed:@"button_previous"];
  UIImage *rightButtonImage = [UIImage imageNamed:@"button_next"];
  UIImage *fillButtonImage = [UIImage imageNamed:@"button_brush"];
  UIImage *eraseButtonImage = [UIImage imageNamed:@"button_eraser_disabled"];
  
  // Palette position calculations
  // X-pos
  CGFloat paletteLeftX = (buttonWidth / 2) - colorButtonSize;
  CGFloat paletteLeft2X = (buttonWidth / 2);
  CGFloat paletteRight2X = (_screenWidth - ((buttonWidth / 2))) - colorButtonSize;
  CGFloat paletteRightX = (_screenWidth - (buttonWidth / 2));
  
  
  // Button position calculations
  CGFloat leftButtonPositionX = (buttonWidth / 2) - (leftButtonImage.size.width / 2);
  CGFloat rightButtonPositionX = (_screenWidth - (buttonWidth / 2)) - (rightButtonImage.size.width / 2);
  CGFloat fillButtonPositionX = (buttonWidth / 2) - (fillButtonImage.size.width / 2);
  CGFloat eraserButtonPositionX = (_screenWidth - (buttonWidth / 2)) - (fillButtonImage.size.width / 2);
  CGFloat leftButtonPositionY = 0;
  CGFloat rightButtonPositionY = 0;
  CGFloat fillButtonPositionY = 0;
  CGFloat eraserButtonPositionY = 0;
  
  if (sIsTablet) {
    leftButtonPositionY = 10;
    rightButtonPositionY = 10;
    fillButtonPositionY = _screenHeight - (fillButtonImage.size.height) - 10;
    eraserButtonPositionY = _screenHeight - (eraseButtonImage.size.height) - 10;
  }
  else {
    leftButtonPositionY = 4;
    rightButtonPositionY = 4;
    fillButtonPositionY = _screenHeight - (fillButtonImage.size.height) - 4;
    eraserButtonPositionY = _screenHeight - (eraseButtonImage.size.height) - 4;
  }
  
  // Previous button.
  _mIbLeft = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbLeft addTarget:self
               action:@selector(onClick:)
     forControlEvents:UIControlEventTouchUpInside];
  [_mIbLeft setImage:leftButtonImage forState:UIControlStateNormal];
  _mIbLeft.frame = CGRectMake(leftButtonPositionX,
                              leftButtonPositionY,
                              leftButtonImage.size.width,
                              leftButtonImage.size.height);
  [_mIbLeft setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbLeft setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbLeft setTag:9];
  
  // Next button.
  _mIbRight = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbRight addTarget:self
                action:@selector(onClick:)
      forControlEvents:UIControlEventTouchUpInside];
  [_mIbRight setImage:rightButtonImage forState:UIControlStateNormal];
  _mIbRight.frame = CGRectMake(rightButtonPositionX,
                               rightButtonPositionY,
                               rightButtonImage.size.width,
                               rightButtonImage.size.height);
  [_mIbRight setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbRight setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbRight setTag:10];
  
  // Color mode toggle button.
  _mTbFillMode = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mTbFillMode addTarget:self
                   action:@selector(onClick:)
         forControlEvents:UIControlEventTouchUpInside];
  [_mTbFillMode setImage:fillButtonImage forState:UIControlStateNormal];
  _mTbFillMode.frame = CGRectMake(fillButtonPositionX,
                                  fillButtonPositionY,
                                  fillButtonImage.size.width,
                                  fillButtonImage.size.height);
  [_mTbFillMode setContentMode:UIViewContentModeScaleAspectFit];
  [_mTbFillMode setAutoresizingMask:UIViewAutoresizingNone];
  [_mTbFillMode setTag:11];
  
  // Eraser toggle button.
  _mTbEraseMode = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mTbEraseMode addTarget:self
                    action:@selector(onClick:)
          forControlEvents:UIControlEventTouchUpInside];
  [_mTbEraseMode setImage:eraseButtonImage forState:UIControlStateNormal];
  _mTbEraseMode.frame = CGRectMake(eraserButtonPositionX,
                                   eraserButtonPositionY,
                                   eraseButtonImage.size.width,
                                   eraseButtonImage.size.height);
  [_mTbEraseMode setContentMode:UIViewContentModeScaleAspectFit];
  [_mTbEraseMode setAutoresizingMask:UIViewAutoresizingNone];
  [_mTbEraseMode setTag:12];
  
  
  // Create the views for the palettes.
  _mLlColorPaletteLeft = [[UIView alloc] initWithFrame:CGRectMake(paletteLeftX,
                                                                  (_screenHeight / 2) - (totalPaletteHeight / 2),
                                                                  paletteWidth,
                                                                  totalPaletteHeight)];
  _mLlColorPaletteLeft2 = [[UIView alloc] initWithFrame:CGRectMake(paletteLeft2X,
                                                                   (_screenHeight / 2) - (totalPaletteHeight / 2),
                                                                   paletteWidth,
                                                                   totalPaletteHeight)];
  _mLlColorPaletteRight = [[UIView alloc] initWithFrame:CGRectMake(paletteRight2X,
                                                                   (_screenHeight / 2) - (totalPaletteHeight / 2),
                                                                   paletteWidth,
                                                                   totalPaletteHeight)];
  _mLlColorPaletteRight2 = [[UIView alloc] initWithFrame:CGRectMake(paletteRightX,
                                                                    (_screenHeight / 2) - (totalPaletteHeight / 2),
                                                                    paletteWidth,
                                                                    totalPaletteHeight)];
  
  // Add the views to the main view.
  [[self view] addSubview:_mIbLeft];
  [[self view] addSubview:_mIbRight];
  [[self view] addSubview:_mTbFillMode];
  [[self view] addSubview:_mTbEraseMode];
  
  [[self view] addSubview:_mLlColorPaletteLeft];
  [[self view] addSubview:_mLlColorPaletteLeft2];
  [[self view] addSubview:_mLlColorPaletteRight];
  [[self view] addSubview:_mLlColorPaletteRight2];
  
  
  // Set the left Palette buttons on the screen.
  [[_hmPalette objectForKey:@"Palette1"] addToView:_mLlColorPaletteLeft];
  
  // Set the left Palette buttons on the screen.
  [[_hmPalette objectForKey:@"Palette2"] addToView:_mLlColorPaletteLeft2];
  
  // Set the right Palette buttons on the screen.
  [[_hmPalette objectForKey:@"Palette3"] addToView:_mLlColorPaletteRight];
  
  // Set the right Palette buttons on the screen.
  [[_hmPalette objectForKey:@"Palette4"] addToView:_mLlColorPaletteRight2];
  
}

- (void)loadImage {
  
  // If the user goes below the minimum possible image, we cycle around
  // back
  // to the max.
  if (_sCurrentImageId < _mMinImageId) {
    _sCurrentImageId = _mMaxImageId;
  }
  
  // If the user goes above the maximum possible image, we cycle around
  // back
  // to the min.
  if (_sCurrentImageId > _mMaxImageId) {
    _sCurrentImageId = _mMinImageId;
  }
  
  // Get the node resource based on the currently selected image id.
  Node *node = [_mNodeData objectAtIndex:_sCurrentImageId];
  // Find the image resource based on the coloring book id and the image
  // id.
  NSString *mResourceName = node.body;
  // Find the image resource based on the coloring book id and the image
  // id.
  NSString *mResourcePaint = [mResourceName stringByAppendingString:@"_map"];
  
  // Get the resource id based on the image's file name.
  NSString *resId = mResourceName;
  
  // Ensure that the image is sized to fit to screen.
  UIImage *picture = [self decodeImage:resId];
  
  // Instantiate the renderer if it doesn't yet exist.
  if (_colorGFX == nil) {
    
    // Position the canvas in the center of the screen.
    CGFloat centerPosX = (_screenWidth / 2) - (picture.size.width / 2);
    CGFloat centerPosY = (_screenHeight / 2) - (picture.size.height / 2);
    
    _colorGFX = [[ColorGFX alloc] initWithContext:self
                                            frame:CGRectMake(centerPosX,
                                                             centerPosY,
                                                             picture.size.width,
                                                             picture.size.height)];
  }
  else {
    // Clear the previous image and colors from the canvas.
    if (_colorGFX.pathCanvas != nil) {
      [_colorGFX clearCanvas:_colorGFX.pathCanvas];
    }
  }
  
  // Clear the bitmaps from the screen.
  _colorGFX.isNextImage = YES;
  
  // Set the canvas's bitmap image so it can be drawn on canvas's run
  // method.
  _colorGFX.pictureBitmapBuffer = picture;
  
  // Set the canvas's paint map.
  _colorGFX.paintBitmapName = mResourcePaint;
  
  // Invoke a redraw of the entire canvas.
  [_colorGFX setNeedsDisplay];
}

- (UIImage *)decodeImage:(NSString*)resId {
  
  // Get the screen width and height.
  CGFloat screenWidth = _screenWidth;
  CGFloat screenHeight = _screenHeight;
  
  // Get the image resource information
  UIImage *imageInfo = [UIImage imageNamed:resId];
  
  CGFloat inSampleSize = 1;
  CGFloat imageWidth = imageInfo.size.width;
  CGFloat imageHeight = imageInfo.size.height;
  
  // The failed scale image bounds
  CGFloat newWidth;
  CGFloat newHeight;
  
  // If the scale fails, we will need to use more memory to perform
  // scaling for the layout to work on all size screens.
  BOOL scaleFailed = NO;
  CGFloat resizeRatioHeight = 1;
  
  // THIS IS DESIGNED FOR FITTING ON THE SCREEN WITH NO SCROLLBAR
  
  // Scale down if the image width exceeds the screen width.
  if (imageWidth > screenWidth || imageHeight > screenHeight) {
    
    // If we need to resize the image because the width or height is too
    // big, get the resize ratios for width and height.
    resizeRatioHeight = imageHeight / screenHeight;
    
    // Get the smaller ratio.
    inSampleSize = resizeRatioHeight;
    
    if (inSampleSize <= 1) {
      scaleFailed = YES;
    }
    
  }
  
  // If the scale failed, that means a scale was needed but didn't happen.
  // We need to create a scaled copy of the image by allocating more
  // memory.
  if (scaleFailed) {
    newWidth = imageInfo.size.width / resizeRatioHeight;
    newHeight = imageInfo.size.height / resizeRatioHeight;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [imageInfo drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    imageInfo = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }
  else {
    // No scaling was needed in the first place!
    imageInfo = imageInfo;
    newWidth = imageWidth;
    newHeight = imageHeight;
  }
  
  return imageInfo;
}

- (IBAction)onClick:(id)sender
{
  
  switch ([sender tag]) {
      
      // The previous button
    case 9: {
      
      // Switch to the previous image.
      _sCurrentImageId--;
      // Set the direction boolean for table row skipping if an id
      // doesn't
      // exist.
      _isDirectionRight = NO;
      
      // If the user goes below the minimum possible image, we cycle
      // around back
      // to the max.
      if (_sCurrentImageId < _mMinImageId) {
        _sCurrentImageId = _mMaxImageId;
      }
      
      // If a fill op is happening, kill it.
      if (_colorGFX.isThreadRunning) {
        _colorGFX.isThreadBroken = YES;
      }
      
      // Load the image.
      [self loadImage];
      
    }
      break;
      
      // The next button
    case 10: {
      
      // Switch to the next image.
      _sCurrentImageId++;
      // Set the direction boolean for table row skipping if an id
      // doesn't
      // exist.
      _isDirectionRight = YES;
      
      // If the user goes above the maximum possible image, we cycle
      // around back
      // to the min.
      if (_sCurrentImageId > _mMaxImageId) {
        _sCurrentImageId = _mMinImageId;
      }
      
      // If a fill op is happening, kill it.
      if (_colorGFX.isThreadRunning) {
        _colorGFX.isThreadBroken = YES;
      }
      
      // Load the image.
      [self loadImage];
      
    }
      break;
      
      // The color mode toggle button
    case 11: {
      
      _mTbFillMode.selected = !(_mTbFillMode.selected);
      
      // Check to see if erase mode is enabled.
      if (_mTbEraseMode.selected) {
        // If it is, simply set this button as the enabled button.
        
        // Prevent toggle.
        _mTbFillMode.selected = !(_mTbFillMode.selected);
        _colorGFX.isFillModeEnabled = _mTbFillMode.selected;
        
        // Disable erase mode
        [_colorGFX setBlendModeForContext:_colorGFX.pathCanvas
                                blendMode:kCGBlendModeNormal];
        // Set the blur mode on again for path drawing.
        // colorGFX.paint.setMaskFilter(mBlur);
        // Set the isEraseModeEnabled boolean
        _colorGFX.isEraseModeEnabled = NO;
        
        // Turn the eraser button off.
        _mTbEraseMode.selected = NO;
        
        // Replace the drawable with the color versions.
        _currentTbStatus = @"";
      }
      else {
        _colorGFX.isFillModeEnabled = _mTbFillMode.selected;
      }
      
      // Update the toggle button image.
      if (_mTbFillMode.selected) {
        // If this toggle button is disabled, the disabled string will be
        // appended to the image names.
        [_mTbFillMode setImage:[UIImage imageNamed:[@"button_bucket" stringByAppendingString:_currentTbStatus]]
                      forState:UIControlStateNormal];
        
      }
      else {
        
        [_mTbFillMode setImage:[UIImage imageNamed:[@"button_brush" stringByAppendingString:_currentTbStatus]]
                      forState:UIControlStateNormal];
        
      }
      
      // Update the toggle button image.
      if (_mTbEraseMode.selected) {
        
        [_mTbEraseMode setImage:[UIImage imageNamed:@"button_eraser"]
                       forState:UIControlStateNormal];
        
      }
      else {
        
        [_mTbEraseMode setImage:[UIImage imageNamed:@"button_eraser_disabled"]
                       forState:UIControlStateNormal];
        
      }
      
    }
      break;
      
      // The eraser toggle button
    case 12: {
      
      _mTbEraseMode.selected = !(_mTbEraseMode.selected);
      
      if (_mTbEraseMode.selected) {
        
        // Set the disabled image resources for the brush and fill
        // buttons.
        _currentTbStatus = @"_disabled";
        
        // Set the current brush mode to erase.
        [_colorGFX setBlendModeForContext:_colorGFX.pathCanvas
                                blendMode:kCGBlendModeDestinationOut];
        _colorGFX.mHard = YES;
        // Take the blur mode off for the eraser.
        // colorGFX.paint.setMaskFilter(null);
        // Set the colorGFX isEraseModeEnabled Boolean
        _colorGFX.isEraseModeEnabled = YES;
        [_mTbEraseMode setImage:[UIImage imageNamed:@"button_eraser"]
                       forState:UIControlStateNormal];
      }
      else {
        // Set the enabled image resources for the brush and fill
        // buttons.
        _currentTbStatus = @"";
        
        //colorGFX.paint.setXfermode(null);
        [_colorGFX setBlendModeForContext:_colorGFX.pathCanvas
                                blendMode:kCGBlendModeNormal];
        _colorGFX.mHard = NO;
        
        // Set the blur mode on again for path drawing.
        //colorGFX.paint.setMaskFilter(mBlur);
        // Set the isEraseModeEnabled boolean
        _colorGFX.isEraseModeEnabled = NO;
        [_mTbEraseMode setImage:[UIImage imageNamed:@"button_eraser_disabled"]
                       forState:UIControlStateNormal];
      }
      
      // Update the toggle button image.
      if (_mTbFillMode.selected) {
        // If this toggle button is disabled, the disabled string will be appended to the image names.
        [_mTbFillMode setImage:[UIImage imageNamed:[@"button_bucket" stringByAppendingString:_currentTbStatus]]
                      forState:UIControlStateNormal];
        
      }
      else {
        
        [_mTbFillMode setImage:[UIImage imageNamed:[@"button_brush" stringByAppendingString:_currentTbStatus]]
                      forState:UIControlStateNormal];
        
      }
      
    }
      break;
      
      // The return button.
    case 13: {
      
      // Display and alert view to confirm whether or not the user wants to exit
      // the coloring book.
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Return To Main Menu" message:@"Do you want to return to the main menu?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
      [alert show];
      
    }
      
      break;
  }
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (buttonIndex) {
    // The cancel button.
    case 0: {
      
      // DO NOTHING.
      
    }
      
      break;
      
    // The confirm button.
    case 1: {
      
      // If a fill op is happening, kill it.
      if (_colorGFX.isThreadRunning) {
        _colorGFX.isThreadBroken = YES;
      }
      
      // Pop the current view controller.
      [self.navigationController popViewControllerAnimated:YES];
      
    }
      break;
      
    // The default case.
    default: {
      
      // DO NOTHING.
      
    }
      
      break;
  }
  
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

+ (BOOL)getIsTablet {
  return sIsTablet;
}

+ (BOOL)getIsLarge {
  return sIsLarge;
}

@end
