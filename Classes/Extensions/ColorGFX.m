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

//
// Copyright (c) 2007 Andrew Finnell
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the “Software”), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "ColorGFX.h"
#import "ColorViewController.h"

// Tolerance to determine whether a touch event should be drawn.
static NSInteger const TOUCH_TOLERANCE = 4;

@implementation ColorGFX

@synthesize isThreadRunning = _isThreadRunning;
@synthesize isThreadBroken = _isThreadBroken;
@synthesize mRunnableCounter = _mRunnableCounter;
@synthesize selectedColor = _selectedColor;
@synthesize isFillEnabled = _isFillEnabled;
@synthesize isFillModeEnabled = _isFillModeEnabled;
@synthesize isEraseModeEnabled = _isEraseModeEnabled;
@synthesize imageWidth = _imageWidth;
@synthesize imageHeight = _imageHeight;
@synthesize isNextImage = _isNextImage;
@synthesize paintBitmapName = _paintBitmapName;
@synthesize pictureBitmapBuffer = _pictureBitmapBuffer;
@synthesize mFloodfillList = _mFloodfillList;
@synthesize mStrokefillList = _mStrokefillList;
@synthesize movePathCanvas = _movePathCanvas;
@synthesize pathCanvas = _pathCanvas;
@synthesize mHard = _mHard;
@synthesize mCurrentPathCanvasBlendMode = _mCurrentPathCanvasBlendMode;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

- (id)initWithContext:(ColorViewController *)colorViewController
                frame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _mContext = colorViewController;
    _selectedColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    _isThreadRunning = NO;
    _isThreadBroken = NO;
    _mRunnableCounter = 0;
    _isFillEnabled = NO;
    _isFillModeEnabled = NO;
    _isEraseModeEnabled = NO;
    _isNextImage = NO;
    _mIsDrawn = NO;
    //_mStrokefillList = [[NSMutableArray alloc] init];
    //_mFloodfillList = [[NSMutableArray alloc] init];
    _mMask = nil;
    
    // Set the context for each canvas.
    [self initContext:&_pathCanvas frame:frame.size];
    [self initContext:&_movePathCanvas frame:frame.size];
    
    // Extract the width and height from the set frame.
    _imageWidth = frame.size.width;
    _imageHeight = frame.size.height;
    
    // BRUSH STYLES
    _mRadius = 6;
    // Create the shape of the tip of the brush. Code currently assumes the
    // bounding	box of the shape is square (height == width)
    _mShape = CGPathCreateMutable();
    CGPathAddEllipseInRect(_mShape,
                           nil,
                           CGRectMake(0, 0, 2 * _mRadius, 2 * _mRadius));
    //CGPathAddRect(mShape, nil, CGRectMake(0, 0, 2 * mRadius, 2 * mRadius));
    
    
  }
  return self;
}


// Releases any contexts created during initialization.
- (void)dealloc {
  
	// Free up our bitmap contexts
	CGContextRelease(_movePathCanvas);
	CGContextRelease(_pathCanvas);
  
  // Clean up our shape and color
	CGPathRelease(_mShape);
  if (_mColor != NULL) {
    CGColorRelease(_mColor);
  }
}

- (void)initContext:(CGContextRef *)argCanvas frame:(CGSize)size {
  // NSInteger bitmapByteCount;
  NSInteger bitmapBytesPerRow;
  
  // Declare the number of bytes per row. Each pixel in the bitmap in this
  // examples is represented by 4 bytes 8 bits each of rgba. (android ARG_8888)
  bitmapBytesPerRow = (size.width * 4);
  // bitmapByteCount = (size.width * 4); // 16-byte aligned is good;
  
  // Allocate memory for image data. This is the destination in memory
  // where any drawing to the bitmap context will be rendered. No needed if
  // first argument of bitmap context creation is NULL (the system will take
  // care of it in this case).
  /*
   cacheBitmap = malloc(bitmapByteCount);
   if (cacheBitmap == NULL) {
   return NO;
   }
   */
  
  CGFloat scale = [[UIScreen mainScreen] scale];
  *argCanvas = CGBitmapContextCreate(NULL,
                                     size.width * scale,
                                     size.height * scale,
                                     8,
                                     bitmapBytesPerRow * scale,
                                     CGColorSpaceCreateDeviceRGB(),
                                     kCGImageAlphaPremultipliedLast);
  CGContextScaleCTM(*argCanvas, scale, scale);
  
  // Make this canvas transparent.
  CGContextSetRGBFillColor(*argCanvas, 1.0, 1.0, 1.0, 0.0);
  CGContextFillRect(*argCanvas, self.bounds);
}

- (void)setBrushStyles:(CGContextRef)argCanvas {
  
  // NOTE: Global brush properties are currently set in init. (look for brush
  // styles under init).

  // Enable anti aliasing.
  CGContextSetAllowsAntialiasing(argCanvas, YES);
  CGContextSetShouldAntialias(argCanvas, YES);
  CGContextSetStrokeColorWithColor(argCanvas, _selectedColor.CGColor);
  CGContextSetLineCap(argCanvas, kCGLineCapRound);
  CGContextSetLineWidth(argCanvas, _mRadius * 2);
  CGContextSetLineJoin(argCanvas, kCGLineJoinRound);
  
  // The "softness" of the brush edges
  _mSoftness = 1.0;
  _mHard = NO;
  
}

- (CGContextRef)createBitmapContext {
	// Create the offscreen bitmap context that we can draw the brush tip into.
	//	The context should be the size of the shape bounding box.
	CGRect boundingBox = CGPathGetBoundingBox(_mShape);
	
	size_t width = CGRectGetWidth(boundingBox);
	size_t height = CGRectGetHeight(boundingBox);
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = ((width * 4) + 0x0000000F) & ~0x0000000F; // 16 byte aligned is good
	//size_t dataSize = bytesPerRow * height;
	//void* data = calloc(1, dataSize);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorspace,
                                                     kCGImageAlphaPremultipliedFirst);
	
	CGColorSpaceRelease(colorspace);
  
	// Clear the context to transparent, 'cause we'll be using transparency
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, width, height));
	
	return bitmapContext;
}

- (void)disposeBitmapContext:(CGContextRef)bitmapContext {
	// Free up the offscreen bitmap
	CGContextRelease(bitmapContext);
}

- (CGImageRef)createShapeImage {
	// Create a bitmap context to hold our brush image
	CGContextRef bitmapContext = [self createBitmapContext];
	
	// If we're not going to have a hard edge, set the alpha to 50% (using a
	//	transparency layer) so the brush strokes fade in and out more.
	if ( !_mHard ) {
		CGContextSetAlpha(bitmapContext, 0.25);
  }
	CGContextBeginTransparencyLayer(bitmapContext, nil);
  
  CGFloat softness;
  // If erase mode is on, turn on hardness and set the color black.
  if (_isEraseModeEnabled) {
    // I like a little color in my brushes
    CGContextSetFillColorWithColor(bitmapContext, [UIColor blackColor].CGColor);
    CGContextSetAlpha(bitmapContext, 1.0);
    softness = 0.0;
  }
	else {
    // I like a little color in my brushes
    CGContextSetFillColorWithColor(bitmapContext, _mColor);
    softness = _mSoftness;
  }
	
	// The way we acheive "softness" on the edges of the brush is to draw
	//	the shape full size with some transparency, then keep drawing the shape
	//	at smaller sizes with the same transparency level. Thus, the center
	//	builds up and is darker, while edges remain partially transparent.
	
	// First, based on the softness setting, determine the radius of the fully
	//	opaque pixels.
	int innerRadius = (int)ceil(softness * (0.5 - _mRadius) + _mRadius);
	int outerRadius = (int)ceil(_mRadius);
	int i = 0;
	
	// The alpha level is always proportial to the difference between the inner,
  // opaque	radius and the outer, transparent radius.
	CGFloat alphaStep = 1.0 / (outerRadius - innerRadius + 1);
	
	// Since we're drawing shape on top of shape, we only need to set the alpha
  // once
	CGContextSetAlpha(bitmapContext, alphaStep);
	
	for (i = outerRadius; i >= innerRadius; --i) {
		CGContextSaveGState(bitmapContext);
		
		// First, center the shape onto the context.
		CGContextTranslateCTM(bitmapContext, outerRadius - i, outerRadius - i);
    
		// Second, scale the the brush shape, such that each successive iteration
		//	is two pixels smaller in width and height than the previous iteration.
		CGFloat scale = (2.0 * i) / (2.0 * outerRadius);
		CGContextScaleCTM(bitmapContext, scale, scale);
    
		// Finally, actually add the path and fill it
		CGContextAddPath(bitmapContext, _mShape);
		CGContextEOFillPath(bitmapContext);
    
		CGContextRestoreGState(bitmapContext);
	}
	
	// We're done drawing, composite the tip onto the context using whatever
	//	alpha we had set up before BeginTransparencyLayer.
	CGContextEndTransparencyLayer(bitmapContext);
	
	// Create the brush tip image from our bitmap context
	CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
	
	// Free up the offscreen bitmap
	[self disposeBitmapContext:bitmapContext];
	
	return image;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  
  // Drawing code
  
  if (_isNextImage) {
    // If new images have been set in the buffer, load them before
    // the next draw.
    [self loadNewImages];
    
    _isNextImage = NO;
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Draw the background.
	// Clear the buffer
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextFillRect(context, self.bounds);
  
  
  // Draw the backup eraser bitmap.
  if (_pictureBitmap != nil) {
    [_pictureBitmap drawInRect:self.bounds];
  }
  
  // Only reset the path once it has been drawn to the pathCanvas.
  if (_mIsDrawn) {
    [self clearCanvas:_movePathCanvas];
    _mIsDrawn = NO;
  }
  
  // Draw the main path.
  CGImageRef cacheImage = CGBitmapContextCreateImage(_pathCanvas);
  CGContextDrawImage(context, self.bounds, cacheImage);
  CGImageRelease(cacheImage);
  
  // Draw the live move path.
  CGImageRef moveImage = CGBitmapContextCreateImage(_movePathCanvas);
  CGContextDrawImage(context, self.bounds, moveImage);
  CGImageRelease(moveImage);
  
  // Draw the strokes bitmap.
  if (_pictureBitmap != nil) {
    [_pictureBitmap drawInRect:self.bounds];
  }
}

- (void)loadNewImages {
  
  if (_pictureBitmap != nil) {
    // Recycle the old bitmap.
    _pictureBitmap = nil;
  }
  
  NSInteger counter = 0;
  
  // Use a loop to ensure all bitmaps get loaded and prevent any potential
  // race conditions.
  while (YES) {
    
    _pictureBitmap = [_pictureBitmapBuffer copy];
    
    // If all bitmaps are loaded, break out of the loop.
    if (_pictureBitmap != nil) {
      break;
    }
    else if (counter > 1000) {
      // TODO: throw a timeout exception. Resource is not loading or
      // something is hanging. Right now we'll just break so we don't
      // over consume resources. The error might simply crash the
      // program for the user if this ever happens.
      break;
    }
    
    counter++;
  }
  
  // Clear the buffers for future use.
  _pictureBitmapBuffer = nil;
}

- (void)clearCanvas:(CGContextRef)canvas {
  
  CGContextClearRect(canvas, self.bounds);
  
}

#pragma mark -
#pragma mark Touches

- (void)touchEventX:(CGFloat *)x y:(CGFloat *)y {
  
  // Set defaults as per the bounds hit. This way, the draw limit is
  // AT the bounds and any path draws aren't interrupted just because
  // a user tries to go out of bounds. This will allow for erases and
  // draws at edges to not be interrupted producing artifacts or give
  // them a hard time trying to erase/draw near the bounds.
  
  // If the user exceeds any bound.
  if (*x < 0) {
    // Check if a draw has previously occured within bounds.
    if (_lastX == -1) {
      // If not, then use the default bound limit.
      *x = 0;
    } else {
      // Else, use the last acceptable inbound position.
      *x = _lastX;
    }
  }
  // Do the same for the upper bound limit.
  else if (*x > _imageWidth) {
    if (_lastX == -1) {
      *x = _imageWidth;
    } else {
      *x = _lastX;
    }
  }
  // If a user is in bound...
  else {
    // Locally cache the bound for future out of bound handling.
    _lastX = *x;
  }
  
  // Rinse and repeat for y.
  if (*y < 0) {
    if (_lastY == -1) {
      *y = 0;
    } else {
      *y = _lastY;
    }
  }
  else if (*y > _imageHeight) {
    if (_lastY == -1) {
      *y = _imageHeight;
    } else {
      *y = _lastY;
    }
  }
  else {
    _lastY = *y;
  }
  
}

// Implements touchesBegan. Starts a new path.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch*	touch = [[event touchesForView:self] anyObject];
  // Convert touch point from UIView referential to OpenGL one (upside-down
  // flip)
  CGPoint _location = [touch locationInView:self];
  _leftoverDistance = 0.0;
  
  // Call the touch position validator.
  [self touchEventX:&_location.x y:&_location.y];
  
  if (!_isFillModeEnabled || _isEraseModeEnabled) {
    
    // Initialize all the tracking information. This includes creating an image
    //	of the brush tip
    
    // Release the previous brush tip image if it exists.
    if (_mMask != NULL) {
      CGImageRelease(_mMask);
    }
    
    // Create a new brush tip image.
    _mMask = [self createShapeImage];
    
    _mX = _location.x;
    _mY = _location.y;
    
  }
}

// Implements touchesMoved. Moves the path.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch*			touch = [[event touchesForView:self] anyObject];
  CGPoint _location;
  CGPoint _previousLocation;
  
  _location = [touch locationInView:self];
  _previousLocation.x = _mX;
  _previousLocation.y = _mY;
  
  // New location validator.
  [self touchEventX:&_location.x y:&_location.y];
  
  if (!_isFillModeEnabled || _isEraseModeEnabled) {
    
    // Render the stroke
    [self renderLineFromPoint:_previousLocation
                      toPoint:_location
       willRenderEntireScreen:NO];
    
    _mX = _location.x;
    _mY = _location.y;
  }
}

// Implements touchesEnded. Completes the path.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

  UITouch*	touch = [[event touchesForView:self] anyObject];
  CGPoint _location;
  CGPoint _previousLocation;
  
  _location = [touch locationInView:self];
  _previousLocation.x = _mX;
  _previousLocation.y = _mY;
  
  
  // New location validator.
  [self touchEventX:&_location.x y:&_location.y];
  
  if (!_isFillModeEnabled || _isEraseModeEnabled) {
    
    //_previousLocation.y = bounds.size.height - _previousLocation.y;
    [self renderLineFromPoint:_previousLocation
                      toPoint:_location
       willRenderEntireScreen:YES];
    
    // Copy the movePathCanvas to pathCanvas
    CGImageRef imageRef = CGBitmapContextCreateImage(_movePathCanvas);
    CGContextDrawImage(_pathCanvas, self.bounds, imageRef);
    CGImageRelease(imageRef);
    
    _mIsDrawn = YES;
  }
  else {
    _isFillEnabled = YES;
    [self fillHandlerX:_location.x y:_location.y];
  }
}

// Implements touchesCancelled. Completes the path.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

  
}

- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
     willRenderEntireScreen:(BOOL)shouldRenderScreen {
  
  // Calculate the bounding rectangle.
  CGFloat boundsX1 = start.x;
  CGFloat boundsY1 = start.y;
  CGFloat boundsX2 = end.x;
  CGFloat boundsY2 = end.y;
  
  CGFloat boundsOriginX = MIN(boundsX1, boundsX2);
  CGFloat boundsOriginY = MIN(boundsY1, boundsY2);
  CGFloat boundsWidth = fabsf(boundsX2 - boundsX1);
  CGFloat boundsHeight = fabsf(boundsY2 - boundsY1);
  
  CGRect bounds = CGRectMake((boundsOriginX - _mRadius), (boundsOriginY - _mRadius), boundsWidth + (_mRadius * 2), boundsHeight + (_mRadius * 2));
  
  
  static CGFloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0, i;
	
	// Allocate vertex array buffer
	if(vertexBuffer == NULL) {
		vertexBuffer = malloc(vertexMax * 2 * sizeof(CGFloat));
  }
	
	// Set the spacing between the stamps. By trail and error, I've
	//	determined that 1/10 of the brush width (currently hard coded to 20)
	//	is a good interval.
	CGFloat spacing = CGImageGetWidth(_mMask) * 0.1;
	
	// Anything less that half a pixel is overkill and could hurt performance.
	if ( spacing < 0.5 )
		spacing = 0.5;
	
	// Determine the delta of the x and y. This will determine the slope
	//	of the line we want to draw.
	CGFloat deltaX = end.x - start.x;
	CGFloat deltaY = end.y - start.y;
	
	// Normalize the delta vector we just computed, and that becomes our step
  // increment for drawing our line, since the distance of a normalized vector
  // is always 1
	CGFloat distance = sqrt( deltaX * deltaX + deltaY * deltaY );
	CGFloat stepX = 0.0;
	CGFloat stepY = 0.0;
	if ( distance > 0.0 ) {
		CGFloat invertDistance = 1.0 / distance;
		stepX = deltaX * invertDistance;
		stepY = deltaY * invertDistance;
	}
	
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
	
	// We're careful to only stamp at the specified interval, so its possible
	//	that we have the last part of the previous line left to draw. Be sure
	//	to add that into the total distance we have to draw.
	CGFloat totalDistance = _leftoverDistance + distance;
  CGFloat refDistance = totalDistance;

  i = 0;
  // While we still have distance to cover, stamp
	while ( totalDistance >= spacing ) {
		// Increment where we put the stamp
		if ( _leftoverDistance > 0 ) {
			// If we're making up distance we didn't cover the last
			//	time we drew a line, take that into account when calculating
			//	the offset. leftOverDistance is always < spacing.
			offsetX += stepX * (spacing - _leftoverDistance);
			offsetY += stepY * (spacing - _leftoverDistance);
			
			_leftoverDistance -= spacing;
		} else {
			// The normal case. The offset increment is the normalized vector
			//	times the spacing
			offsetX += stepX * spacing;
			offsetY += stepY * spacing;
		}
    
    if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(CGFloat));
		}
    
    vertexBuffer[2 * vertexCount + 0] = ([self quadCurveWithStartPoint:start.x
                                                          controlPoint:((start.x + end.x) / 2)
                                                              endPoint:end.x
                                                                tValue:((spacing * i) / refDistance)]);
		vertexBuffer[2 * vertexCount + 1] = ([self quadCurveWithStartPoint:start.y
                                                          controlPoint:((start.y + end.y) / 2)
                                                              endPoint:end.y
                                                                tValue:((spacing * i) / refDistance)]);
    
		vertexCount += 1;
    
		// Remove the distance we just covered
		totalDistance -= spacing;
    i++;
	}
	
	// Return the distance that we didn't get to cover when drawing the line.
	//	It is going to be less than spacing.
	_leftoverDistance = totalDistance;
  
	// Render the vertex array
  for (NSUInteger u = 0; u < vertexCount; u++) {
    
    // Calculate where to put the current stamp at.
    CGPoint stampAt = CGPointMake(vertexBuffer[2 * u + 0],
                                  vertexBuffer[2 * u + 1]);
    
    // Ka-chunk! Draw the image at the current location
    
    // When we stamp the image, we want the center of the image to be
    //	at the point specified.
    CGContextSaveGState(_movePathCanvas);
    
    // So we can position the image correct, compute where the bottom left
    //	of the image should go, and modify the CTM so that 0, 0 is there.
    CGPoint bottomLeft = CGPointMake(stampAt.x - CGImageGetWidth(_mMask) * 0.5,
                                     stampAt.y - CGImageGetHeight(_mMask) * 0.5);
    CGContextTranslateCTM(_movePathCanvas, bottomLeft.x, bottomLeft.y);
    
    // Now that it's properly lined up, draw the image
    CGRect maskRect = CGRectMake(0,
                                 0,
                                 CGImageGetWidth(_mMask),
                                 CGImageGetHeight(_mMask));
    CGContextDrawImage(_movePathCanvas, maskRect, _mMask);
    
    CGContextRestoreGState(_movePathCanvas);
  }
  
  // Unless otherwise signaled, only render the bounding box between two points.
  if (!shouldRenderScreen) {
    [self setNeedsDisplayInRect:bounds];
  }
  else {
    [self setNeedsDisplay];
  }
}

- (CGFloat) quadCurveWithStartPoint:(CGFloat)A
                       controlPoint:(CGFloat)B
                           endPoint:(CGFloat)C
                             tValue:(CGFloat)t {
  
  CGFloat s = 1 - t;
  CGFloat AB = A * s + B * t;
  CGFloat BC = B * s + C * t;
  
  return (AB * s + BC * t);
  
}

- (void)fillHandlerX:(CGFloat)x y:(CGFloat)y {
  
  // If the user has set fill mode on...
  if (_isFillModeEnabled) {
    // Check for the fill signal and ensure that a point has been set to
    // begin the flood fill algorithm.
    if (_isFillEnabled) {
      
      // If a fill op is currently happening, do not register a new
      // op!
      if (_mRunnableCounter >= 1) {
        // Signal end of op.
        _isFillEnabled = NO;
        return;
      }
      
      // Get the corresponding fill map file resource.
      NSString *resPaintId = _paintBitmapName;
      
      // Get the image resource information
      UIImage *imageInfo = [UIImage imageNamed:resPaintId];
      
      CGFloat inSampleSize = 1;
      CGFloat fillImageWidth = imageInfo.size.width;
      CGFloat fillImageHeight = imageInfo.size.height;
      
      // The failed scale image bounds
      CGFloat newWidth;
      CGFloat newHeight;
      
      // If the scale fails, we will need to use more memory to perform
      // scaling for the layout to work on all size screens.
      BOOL scaleFailed = NO;
      CGFloat resizeRatioHeight = 1;
      
      // THIS IS DESIGNED FOR FITTING ON THE SCREEN WITH NO SCROLLBAR
      
      // Scale down if the image width exceeds the screen width.
      if (fillImageWidth > _imageWidth || fillImageHeight > _imageHeight) {
        
        // If we need to resize the image because the width or height is too
        // big, get the resize ratios for width and height.
        resizeRatioHeight = fillImageHeight / _imageHeight;
        
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
        newWidth = fillImageWidth;
        newHeight = fillImageHeight;
      }
      
      UIColor *targetColor = [[Colors getRGBAsFromImage:imageInfo
                                                    atX:x
                                                   andY:y
                                                  count:1] objectAtIndex:0];
      
      // If the target color is not black (black means it is the
      // stroke color).
      if (CGColorEqualToColor(targetColor.CGColor,
                              [UIColor colorWithRed:0.0
                                              green:0.0
                                               blue:0.0
                                              alpha:0.0].CGColor)) {
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        // Fill all unbounded pixels of that color.
        CGPoint pointNode = CGPointMake(x * scale, y * scale);
        // Put the point in an object so it can be used in array operations.
        PointNode *node = [[PointNode alloc] init];
        node.node = pointNode;
        
        _mRunnableCounter++;
        
        [_mContext.mPbFloodFill setHidden:NO];
        [_mContext.mPbFloodFill startAnimating];
        
        // Runnable Flood Fill
        LoadViewTask *floodFillTask = [[LoadViewTask alloc] initWithContext:_mContext];
        floodFillTask.image = imageInfo;
        floodFillTask.point = node;
        floodFillTask.target = targetColor;
        floodFillTask.replacementColor = _selectedColor;
        
        // Initialize the handler
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void) {
          
            // Signal the start of the running thread.
            _isThreadRunning = YES;
          
            // Start the main task.
            [floodFillTask start];
          
            // Once the main task is done, run the onPostExecute hook on the
            // main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                // main task is done. Call onPostExecute on the main thread.
                [floodFillTask onPostExecute];
            });
          
          // Signal the end of the running thread.
          _isThreadRunning = NO;
        });
      }
    }
  }
}

- (void)colorPixels:(LoadViewTask *)taskContext
    replacementColor:(UIColor *)replacementColor {
  
  // Define the bitmap width and height.
  NSInteger width = CGImageGetWidth(_pictureBitmap.CGImage);
  NSInteger height = CGImageGetHeight(_pictureBitmap.CGImage);
  
  // Both arrays are the same size, so just choose one to control the
  // iteration.
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      if (_mFloodfillList[height * i + j] != false) {
        [taskContext setPixel:i
                         andY:j
                  replacement:replacementColor];
      }
      if (_mStrokefillList[height * i + j] != false) {
        [taskContext setPixel:i
                         andY:j
                  replacement:replacementColor];
      }
    }
  }
  
}

- (void)clearPixelLists {
  free(_mStrokefillList);
  free(_mFloodfillList);
  _mStrokefillList = NULL;
  _mFloodfillList = NULL;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
  _selectedColor = selectedColor;
  
  CGFloat r, g, b, a;
  //[_selectedColor getRed:&r green:&g blue:&b alpha:&a];
  
  // Do not use the getRed method on UIColors as it is not backwards compatible.
  const CGFloat* rgb = CGColorGetComponents([_selectedColor CGColor]);
  r = rgb[0];
  g = rgb[1];
  b = rgb[2];
  a = CGColorGetAlpha([_selectedColor CGColor]);
  
  if (_mColor != NULL) {
    CGColorRelease(_mColor);
  }
  
  // Create the color for the brush
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGFloat components[] = { r, g, b, a };
  _mColor = CGColorCreate(colorspace, components);
  CGColorSpaceRelease(colorspace);
  
  // Update the brushs styles for the live path canvas and the cached canvas.
  
  // If erase mode is enabled, don't update the live path color, as it will
  // remain black (when erase mode is off, the color will update to the most
  // recent selected color).
  if (!_isEraseModeEnabled) {
    CGContextSetStrokeColorWithColor(_movePathCanvas, _selectedColor.CGColor);
  }
  CGContextSetStrokeColorWithColor(_pathCanvas, _selectedColor.CGColor);
}

- (void)setBlendModeForContext:(CGContextRef)argContext
                     blendMode:(CGBlendMode)blendMode {
  CGContextSetBlendMode(argContext, blendMode);
}

@end
