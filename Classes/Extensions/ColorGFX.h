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
#import "LoadViewTask.h"
#import "PointNode.h"

@class ColorViewController;

// Handles all canvas rendering actions.
@interface ColorGFX : UIView {
  
 @private
  
  // Boolean to determine whether a thread should continue processing or if it
  // should stop.
  BOOL _isThreadBroken;
  // Runnable counter for progress bar.
  NSInteger _mRunnableCounter;
  BOOL _isThreadRunning;
  
  // The id of the currently selected color.
  UIColor *_selectedColor;
  
  // Define whether or not fill is occuring.
  BOOL _isFillEnabled;
  
  // Define whether or not fill mode is enabled (if not, then the mode is
  // considered draw mode).
  BOOL _isFillModeEnabled;
  // Define whether ot not erase mode is enabled (this check is necessary to
  // take precedence over fillMode.
  BOOL _isEraseModeEnabled;
  
  // Image metrics
  CGFloat _imageWidth;
  CGFloat _imageHeight;
  
  // Set the GFX properties.
  
  // Boolean for determining whether or not the canvas should be cleared for
  // the next image load.
  BOOL _isNextImage;
  // The picture bitmap.
  UIImage *_pictureBitmap;
  
  NSString *_paintBitmapName;
  
  // Bitmap buffers used when loading a new bitmap.
  // The picture bitmap.
  UIImage *_pictureBitmapBuffer;
  
  // The path buffers.
  BOOL _mIsDrawn;
  
  // Set brush properties
  // Set a brush emboss.
  // TODO: public MaskFilter emboss;
  // Set a brush blur.
  // TODO: public MaskFilter blur;
  // The color of the path.
  // TODO: public Paint paint;
  // TODO: public Paint bitmapPaint;
  
  // A list of points to floodfill whenever this tool is used.
  NSMutableArray *_mFloodfillList;
  // A list of points to floodfill whenever this tool is used.
  NSMutableArray *_mStrokefillList;
  
  // Other variables defined right before methods in the Android codebase.
  CGFloat _lastX;
  CGFloat _lastY;
  
  // PaintView
  CGContextRef _pathCanvas;
  // The path to draw in draw mode.
  //CGMutablePathRef _mPath;
  // This is needed to render an active (currently being drawn) path to the
  // screen. It works with _mPath.
  CGContextRef _movePathCanvas;
  
  // Brush properties
  NSInteger _mRadius;
  
  // Reference to the master view.
  __unsafe_unretained ColorViewController *_mContext;
  
  // Brush stroke properties.
  CGFloat _mSoftness;
  CGImageRef			_mMask;
  CGMutablePathRef	_mShape;
	CGColorRef			_mColor;
  CGFloat _mX;
  CGFloat _mY;
  CGFloat _leftoverDistance;
}

@property(nonatomic, assign) BOOL isThreadRunning;
@property(nonatomic, assign) BOOL isThreadBroken;
@property(nonatomic, assign) NSInteger mRunnableCounter;
@property(nonatomic, strong) UIColor *selectedColor;
@property(nonatomic, assign) BOOL isFillEnabled;
@property(nonatomic, assign) BOOL isFillModeEnabled;
@property(nonatomic, assign) BOOL isEraseModeEnabled;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, assign) CGFloat imageHeight;
@property(nonatomic, assign) BOOL isNextImage;
@property(nonatomic, copy) NSString *paintBitmapName;
@property(nonatomic, strong) UIImage *pictureBitmapBuffer;
@property(nonatomic, strong) NSMutableArray *mFloodfillList;
@property(nonatomic, strong) NSMutableArray *mStrokefillList;
@property(nonatomic, assign) CGContextRef pathCanvas;
@property(nonatomic, assign) CGContextRef movePathCanvas;
@property(nonatomic, assign) BOOL mHard;

// Main initializer for this UIView.
- (id)initWithContext:(ColorViewController *)colorViewController
                frame:(CGRect)frame;

// Configures a canvas context in preparation for painting.
- (void)initContext:(CGContextRef *)argCanvas frame:(CGSize)size;

// Sets the styles for a canvas.
- (void)setBrushStyles:(CGContextRef)argCanvas;

// Creates and returns a new bitmap context.
- (CGContextRef)createBitmapContext;

// Disposes the passed bitmap context.
- (void)disposeBitmapContext:(CGContextRef)bitmapContext;

// Creates the brush tip whenever a touch event begins.
- (CGImageRef)createShapeImage;

// Loads new images into the main bitmap caches.
- (void)loadNewImages;

// Clears a canvas of any color and makes it fully transparent.
- (void)clearCanvas:(CGContextRef)canvas;

// Handles all user input events to manipulate the screen rendering.
- (void)touchEventX:(CGFloat *)x y:(CGFloat *)y;

// Draws a line onscreen based on where the user touches
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
     willRenderEntireScreen:(BOOL)shouldRenderScreen;

// Returns the point on a curve represented by position t.
- (CGFloat)quadCurveWithStartPoint:(CGFloat)A
                      controlPoint:(CGFloat)B
                          endPoint:(CGFloat)C
                            tValue:(CGFloat)t;

// Handles fill operations when a fill event occurs.
- (void)fillHandlerX:(CGFloat)x y:(CGFloat)y;

// Colors all anti-aliasing pixels for a smooth fill.
- (void)colorStrokes:(LoadViewTask *)taskContext
    replacementColor:(UIColor *)replacementColor;

// Colors all pixels from the flood fill algorithm.
- (void)colorPixels:(LoadViewTask *)taskContext
   replacementColor:(UIColor *)replacementColor;

// Clears the stroke and floodfill pixel lists.
- (void)clearPixelLists;

// Sets a newly selected color.
- (void)setSelectedColor:(UIColor *)selectedColor;

// Set a new blend mode for the specified context.
- (void)setBlendModeForContext:(CGContextRef)argContext
                     blendMode:(CGBlendMode)blendMode;

@end
