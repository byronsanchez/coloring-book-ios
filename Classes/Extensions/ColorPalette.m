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

#import "ColorPalette.h"

// A boolean to store the last selected color for ColorPalette.java's
// highlights.
static NSString *sLastTag = @""; //

@implementation ColorPalette

@synthesize mColors = _mColors;
@synthesize mIbColors = _mIbColors;
@synthesize buttonSize = _buttonSize;

// Implements init.
- (id)init {
  
  if(!(self = [super init])) {
    return nil;
  }
  
  // Custom initialization
  _buttonSize = 0;
  _mIbColors = [[NSMutableDictionary alloc] init];
  
  return self;
}

- (id)initWithContext:(ColorViewController *)colorViewController
               colors:(NSMutableDictionary *)colors
{
  if(!(self = [super init])) {
    return nil;
  }
  
  // Default init
  _buttonSize = 0;
  _mIbColors = [[NSMutableDictionary alloc] init];
  
  // Custom initialization
  _mContext = colorViewController;
  _mColors = colors;
  _defaultColor = [UIColor colorWithRed:0/255.0
                                  green:0/255.0
                                   blue:0/255.0
                                  alpha:1.0];
  
  if ([ColorViewController getIsTablet]) {
    _mStrokeSize = 14;
  }
  else {
    _mStrokeSize = 5;
  }
  
  
  return self;
}

- (void)calculateButtonSize {
  
  // Get the screen width, subtract the image width and divide the
  // remaining space by 4, 1 for each of the four color palettes.
  // Get the screen metrics.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  // Use inversed metrics since this application is landscape only.
  CGFloat availableWidth = screenRect.size.height - _mContext.colorGFX.imageWidth;
  CGFloat availableHeight = screenRect.size.width;
  
  CGFloat resultSize;
  
  CGFloat resultWidth = availableWidth / 4;
  CGFloat resultHeight = availableHeight / 8;
  
  // Circle size is dependent on screen size. For fluid layouts, we
  // must determine the maximum amount of circular space to take up
  // without overlaying the canvas. So the minimum of the available
  // space for the width and height is calculated and used.
  if (resultHeight < resultWidth) {
    resultSize = resultHeight;
  }
  else {
    resultSize = resultWidth;
  }
  
  _buttonSize = resultSize;
}

- (void)createButtons {
  
  NSInteger buttonCounter = 0;
  
  NSArray *buttonArray = [[_mColors allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  // Loop through the colors hashmap for this palette
  for (NSString *key in buttonArray) {
    
    /*
     UIImage *shopButtonImage = [UIImage imageNamed:@"button_next"];
     [shopButton setImage:shopButtonImage forState:UIControlStateNormal];
     */
    
    // Create the image button for each color.
    UIButton *newImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newImageButton setContentMode:UIViewContentModeScaleAspectFit];
    [newImageButton setAutoresizingMask:UIViewAutoresizingNone];
    
    // Set the color of the ImageButton to be the one that the Colors
    // HashMap has defined.
    
    // Divide by 4, one for each palette.
    CGFloat paletteWidth = floor(_buttonSize);
    // Divide by 7, one for each palette element (5), the directional
    // buttons (1) and the advanced buttons (1).
    CGFloat paletteHeight = floor(_buttonSize);
    
    // Give the ImageButton some parameters.
    newImageButton.frame = CGRectMake(0,
                                      (buttonCounter * _buttonSize),
                                      paletteWidth,
                                      paletteHeight);
    
    // Set a tag so we can identify this view if an event is fired.
    [newImageButton setStringTag:key];
    
    // Resize the bounds for the shape so the border size is taken into account.
    CGRect borderBounds = newImageButton.frame;
    borderBounds.size.width = (borderBounds.size.width - (_mStrokeSize));
    borderBounds.size.height = (borderBounds.size.height - (_mStrokeSize));
    borderBounds.origin.x = (newImageButton.frame.size.width / 2) + (_mStrokeSize / 2);
    borderBounds.origin.y = (newImageButton.frame.size.height / 2) + (_mStrokeSize / 2);
    
    UIBezierPath *ellipsePath = [UIBezierPath bezierPathWithOvalInRect:borderBounds];
    CAShapeLayer *ellipseShapeLayer = [CAShapeLayer layer];
    // Set the name of the layer so we can modify this layer on color switches.
    ellipseShapeLayer.name = @"borderLayer";
    
    [ellipseShapeLayer setPath:ellipsePath.CGPath];
    UIColor *colorHolder = [_mColors objectForKey:key];
    [ellipseShapeLayer setFillColor:colorHolder.CGColor];
    ellipseShapeLayer.bounds = newImageButton.bounds;
    
    // Calculate the stroke size based on the device being used.
    
    // If the key is the default color, highlight it, because this is
    // the current inital default selected color.
    if (CGColorEqualToColor(colorHolder.CGColor, _defaultColor.CGColor)) {
      [ellipseShapeLayer setStrokeColor:[Colors colorFromHexString:@"FFFFFFBB"].CGColor];
      [ellipseShapeLayer setLineWidth:_mStrokeSize];
      
      [ColorPalette setLastTag:key];
      
    } else {
      [ellipseShapeLayer setStrokeColor:[Colors colorFromHexString:@"FFFFFF44"].CGColor];
      [ellipseShapeLayer setLineWidth:_mStrokeSize];
    }
    
    // Set the context's onClick() listener to each button.
    [newImageButton addTarget:self
                       action:@selector(onClick:)
             forControlEvents:UIControlEventTouchUpInside];
    
    // Render an image based off of the generated gradient and set it as the
    // background.
    // 0 indicate that the image created should be at the scale of the main
    // screen, thus proper scaling for all devices.
    /*
     UIGraphicsBeginImageContextWithOptions(ellipseShapeLayer.frame.size, NO, 0);
     [ellipseShapeLayer renderInContext:UIGraphicsGetCurrentContext()];
     UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     [newImageButton setImage:buttonImage forState:UIControlStateNormal];
     */
    [newImageButton.layer addSublayer:ellipseShapeLayer];
    
    // Add the new image button to the list of palette image buttons.
    // Make sure to tag appropriately with the corresponding color hm
    // tag.
    [_mIbColors setValue:newImageButton forKey:key];
    
    buttonCounter++;
  }
}

- (void)addToView:(UIView *)view {
  
  NSArray *buttonArray = [[_mColors allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  // Loop through the image buttons hashmap for this palette
  for (NSString *key in buttonArray) {
    
    [view.self addSubview:[_mIbColors objectForKey:key]];
    
  }
}

- (IBAction)onClick:(id)sender
{
  // The only registered onClick listeners for this scope are color
  // buttons.
  
  // Identify the button that has been clicked by the tag that was set
  // when the ImageButton was created.
  NSString *tag = [sender getStringTag];
  
  // Determine which palette the click came from...
  
  // Retrieve the corresponding color information.
  UIColor *color = [_mColors objectForKey:tag];
  
  // Get the instance of the context making the call to this Palette
  // Class.
  // ColorActivity activity = (ColorActivity) mContext;
  
  // From that information set the new selectedColor.
  // We use the context to get the activity instance implementing this
  // class.
  [_mContext.colorGFX setSelectedColor:color];
  
  // If a color was previously selected, redraw it to the default stroke.
  if (![[ColorPalette getLastTag] isEqualToString:@""]) {
    // Iterate through each of the available color palettes.
    for (NSString *key in _mContext.hmPalette) {
      // If the current color palette contains the last color,
      // unhighlight it.
      ColorPalette *tempPalette = [_mContext.hmPalette objectForKey:key];
      
      if (([tempPalette.mIbColors objectForKey:[ColorPalette getLastTag]])) {
        // Get the last selected color.
        UIButton *lastView = [tempPalette.mIbColors objectForKey:[ColorPalette getLastTag]];
        
        
        
        // Get the button's shape layer.
        NSArray* sublayers = [NSArray arrayWithArray:lastView.layer.sublayers];
        
        for (CAShapeLayer *lastEllipseShapeLayer in sublayers) {
          
          if ([lastEllipseShapeLayer.name isEqualToString:@"borderLayer"]) {
            // Remove the highlight.
            [lastEllipseShapeLayer setStrokeColor:[Colors colorFromHexString:@"FFFFFF44"].CGColor];
            [lastView setNeedsDisplay];
          }
          
        }
        
        // End the loop.
        break;
      }
    }
  }
  
  // Update the stroke color to highlight the new color.
  UIButton *view = (UIButton *) sender;
  
  // Get the button's shape layer.
  NSArray* sublayers = [NSArray arrayWithArray:view.layer.sublayers];
  
  for (CAShapeLayer *currentEllipseShapeLayer in sublayers) {
    
    if ([currentEllipseShapeLayer.name isEqualToString:@"borderLayer"]) {
      // Remove the highlight.
      [currentEllipseShapeLayer setStrokeColor:[Colors colorFromHexString:@"FFFFFFBB"].CGColor];
      [view setNeedsDisplay];
    }
  }
  
  // Set the tag in an external location where it will persist for all
  // color palettes.
  [ColorPalette setLastTag:tag];
  
}

+ (void)setLastTag:(NSString *)lastTag {
  sLastTag = lastTag;
}

+ (NSString *)getLastTag {
  return sLastTag;
}

@end
