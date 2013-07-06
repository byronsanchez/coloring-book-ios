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

#import "LoadViewTask.h"
#import "ColorViewController.h"

@implementation LoadViewTask

@synthesize point = _point;
@synthesize target = _target;
@synthesize replacementColor = _replacementColor;
@synthesize image = _image;

- (id)initWithContext:(ColorViewController *)colorViewController
{
  if(!(self = [super init])) {
    return nil;
  }
  
  // Custom initialization
  _mContext = colorViewController;
  
  return self;
}

- (void)start {
  [self run];
}

- (void)run {
  
  [self floodFill:_point
      targetColor:_target
 replacementColor:_replacementColor
          picture:_image];
  
}

- (void)onPostExecute {
  if (!_mContext.colorGFX.isThreadBroken) {
    
    // Now that the lists have been generated, we can
    // garbage collect the paint bitmap.
    _image = nil;
    
    // Pass the generated fill and stroke list data back to
    // the UI thread class.
    _mContext.colorGFX.mFloodfillList = _list;
    _mContext.colorGFX.mStrokefillList = _strokeList;
    
    // Create the bitmap that will be added to the paint
    // layer.
    NSUInteger bitmapBytesPerRow2;
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // examples is represented by 4 bytes 8 bits each of rgba.
    // (android ARG_8888)
    bitmapBytesPerRow2 = (_mContext.colorGFX.imageWidth * 4);
    
    /**
     * Transparent bitmap to add color to.
     */
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGContextRef argCanvas = CGBitmapContextCreate(NULL,
                                                   (_mContext.colorGFX.imageWidth * scale),
                                                   (_mContext.colorGFX.imageHeight * scale),
                                                   8,
                                                   bitmapBytesPerRow2 * scale,
                                                   CGColorSpaceCreateDeviceRGB(),
                                                   kCGImageAlphaPremultipliedLast);
    // Make this canvas transparent.
    CGContextSetRGBFillColor(argCanvas, 0.0, 0.0, 0.0, 0.0);
    CGContextScaleCTM(argCanvas, scale, scale);
    CGContextFillRect(argCanvas, _mContext.colorGFX.bounds);
    CGImageRef imageRef = CGBitmapContextCreateImage(argCanvas);
    UIImage *fillPicture = [[UIImage alloc] initWithCGImage:imageRef
                                                      scale:scale
                                                orientation:UIImageOrientationUp];
    CGContextRelease(argCanvas);
    
    // Generate pixel data so we can color this new UIImage.
    [self generatePixelData:fillPicture];
    
    fillPicture = nil;
    
    // Color the list of pixels generated from the flood
    // fill algorithm.
    [_mContext.colorGFX colorPixels:self replacementColor:_replacementColor];
    
    
    /**
     * New bitmap with updated color.
     */
    
    CGContextRef ctx = CGBitmapContextCreate(_rawData,
                                             CGImageGetWidth( imageRef ),
                                             CGImageGetHeight( imageRef ),
                                             8,
                                             CGImageGetBytesPerRow( imageRef ),
                                             CGImageGetColorSpace( imageRef ),
                                             kCGImageAlphaPremultipliedLast );
    CGImageRelease(imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage (ctx);
    CGContextRelease(ctx);
    // UIImage *finalImage = [[UIImage alloc] initWithCGImage:newImageRef];
    
    // Paint filter to draw the paint over what is already
    // on the paint layer.
    //Paint addFilter = new Paint();
    // addFilter.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_OVER));
    
    // Save the flood filled image so it can persist in
    // future flood fills and path draws.
    // mPaintBitmap = picture;
    
    // Quartz uses a lower-left origin coordinate system. The x axis
    // corresponds, but the y axis doesn't. Thus, change the coordinate system
    // for this context.
    
    // Translate the image by its height.
    CGContextTranslateCTM(_mContext.colorGFX.pathCanvas,
                          0,
                          _mContext.colorGFX.bounds.size.height);
    // Inverse the coordinates.
    CGContextScaleCTM(_mContext.colorGFX.pathCanvas, 1.0, -1.0);
    
    // Draw the newly filled image onto the path canvas.
    CGContextDrawImage(_mContext.colorGFX.pathCanvas,
                       _mContext.colorGFX.bounds,
                       newImageRef);
    // [finalImage drawInRect: _mContext.colorGFX.bounds];
    CGImageRelease(newImageRef);
    
    
    // Restore the coordinate system to its default settings
    CGContextTranslateCTM(_mContext.colorGFX.pathCanvas,
                          0,
                          _mContext.colorGFX.bounds.size.height);
    CGContextScaleCTM(_mContext.colorGFX.pathCanvas, 1.0, -1.0);
    
    
    [_mContext.colorGFX setNeedsDisplay];
    [self releasePixelData];
    // pathCanvas.drawBitmap(fillPicture, 0, 0, addFilter);
    
  }

  [_mContext.colorGFX clearPixelLists];
  _list = NULL;
  _strokeList = NULL;

  // Close the progress dialog
  // progressDialog.dismiss();
  _mContext.colorGFX.mRunnableCounter--;
  
  // If there are no more runnables running a flood fill job,
  // remove the progress bar view from the display.
  if (_mContext.colorGFX.mRunnableCounter == 0) {
    [_mContext.mPbFloodFill stopAnimating];
    // Once all threads have ended, we can set the boolean
    // check for threads back to false so they work again.
    _mContext.colorGFX.isThreadBroken = NO;
  }
}

- (void)floodFill:(PointNode *)node
      targetColor:(UIColor *)targetColor
 replacementColor:(UIColor *)replacementColor
          picture:(UIImage *)picture {
  
  // Define the bitmap width and height.
  CGFloat width = CGImageGetWidth(picture.CGImage);
  CGFloat height = CGImageGetHeight(picture.CGImage);
  
  // Initialize the arrays according to the image metrics.
  // Allocate 2 dimensions in one for VERY minimal optimization
  // with regards to false-fill.
  _list = (bool*) malloc(sizeof(bool) * width * height);
  _strokeList =(bool*) malloc(sizeof(bool) * width * height);
  memset(_list, false, sizeof(bool) * width * height);
  memset(_strokeList, false, sizeof(bool) * width * height);
  
  // Define the target and replacement color.
  UIColor *target = targetColor;
  UIColor *replacement = replacementColor;
  
  // If the selected color is not equal to the replacement color...
  // Start the flood fill algorithm.
  if (!CGColorEqualToColor(target.CGColor, replacement.CGColor)) {
    // Set the empty queue and run the algorithm at least once (or
    // alternatively, set the point to the end of queue and run a
    // while loop that performs this algorithm so long as the Queue is not
    // empty).
    NSMutableArray *queue = [[NSMutableArray alloc] init];
    // Get the pixel data from the image.
    [self generatePixelData:picture];
    
    // Run the loop at least once for the selected pixel.
    do {
      
      if (_mContext.colorGFX.isThreadBroken) {
        break;
      }
      
      // Store the current pixel in local variables.
      CGFloat x = node.node.x;
      CGFloat y = node.node.y;
      
      // while x is not at the origin AND the color of it's West
      // neighboring pixel is changeable.
      while (x > 0 && CGColorEqualToColor([self getPixel:(x - 1) andY:y].CGColor, target.CGColor)) {
        // Continuously decrement x (AKA bring x as far to the
        // west as possible given the color constraints).
        x--;
      }
      
      // Given the above while loop, we are now as far West as we
      // can be and are currently at a pixel we will need to replace.
      
      // Set directional booleans.
      BOOL spanUp = NO;
      BOOL spanDown = NO;
      
      // While x has not reached as far East as it can in the
      // bitmap (AKA hasn't hit the end of the image and hasn't reached a
      // color different than the replacement color)...
      while (x < width && CGColorEqualToColor([self getPixel:x andY:y].CGColor, target.CGColor)) {
        
        // Replace the current pixel color.
        [self setPixel:x andY:y replacement:replacement];
        // Add the pixel to the flood fill list.
        _list[(int)(height * x + y)] = true;
        
        // If any of the surrounding pixel's are black, add it
        // to the stroke list.
        
        // TOP
        if (y + 1 < height - 1 && !CGColorEqualToColor([self getPixel:x andY:(y + 1)].CGColor, target.CGColor)) {
          _strokeList[(int)(height * x + (y + 1))] = true;
        }
        
        // RIGHT
        if (x + 1 < width - 1 && !CGColorEqualToColor([self getPixel:(x + 1) andY:y].CGColor, target.CGColor)) {
          _strokeList[(int)(height * (x + 1) + y)] = true;
        }
        
        // LEFT
        if (x - 1 > 0 && !CGColorEqualToColor([self getPixel:(x - 1) andY:y].CGColor, target.CGColor)) {
          _strokeList[(int)(height * (x - 1) + y)] = true;
        }
        
        // BOTTOM
        if (y - 1 > 0 && !CGColorEqualToColor([self getPixel:x andY:(y - 1)].CGColor, target.CGColor)) {
          _strokeList[(int)(height * x + (y - 1))] = true;
        }
        
        // Add one SOUTH point to the queue if it is replaceable
        // (this will be the next relative point to check from) and we have
        // not previously moved down.
        if (!spanUp && y > 0 && CGColorEqualToColor([self getPixel:x andY:(y - 1)].CGColor, target.CGColor)) {
          [queue add:[[PointNode alloc] initWithPoint:CGPointMake(x, y - 1)]];
          spanUp = YES;
        }
        // If the SOUTH point is unreplaceable or we have
        // previously moved up set the boolean to false.
        else if (spanUp && y > 0 && !CGColorEqualToColor([self getPixel:x andY:(y - 1)].CGColor, target.CGColor)) {
          spanUp = NO;
        }
        
        // Add one NORTH point to the queue if it is replaceable
        // (this will be the next relative point to check from) and we have
        // not previously moved up.
        if (!spanDown && y < height - 1
            && CGColorEqualToColor([self getPixel:x andY:(y + 1)].CGColor, target.CGColor)) {
          [queue add:[[PointNode alloc] initWithPoint:CGPointMake(x, y + 1)]];
          spanDown = YES;
        }
        // If the NORTH point is unreplaceable or we have
        // previously moved up set the boolean to false.
        else if (spanDown && y < height - 1
                 && !CGColorEqualToColor([self getPixel:x andY:(y + 1)].CGColor, target.CGColor)) {
          spanDown = NO;
        }
        
        // Increment the x-position, 1 to the east.
        x++;
      }
    }
    // Remove the head of this queue. Keep looping until no pixels
    // remain.
    while ((node = [queue poll]) != nil);
  }
  
  // Free pixel data.
  [self releasePixelData];
  
  // Once the Flood Fill Algorithm has completed, turn the action flag
  // off. We're done.
  _mContext.colorGFX.isFillEnabled = NO;
}

- (void)generatePixelData:(UIImage *)imageInfo {
  
  // imageInfo is now considered the working image for reading/writing pixel
  // data.
  CGImageRef imageRef = [imageInfo CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  _rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
  _bytesPerPixel = 4;
  _bytesPerRow = _bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(_rawData,
                                               width,
                                               height,
                                               bitsPerComponent,
                                               _bytesPerRow,
                                               colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
}

- (UIColor *)getPixel:(CGFloat)x andY:(CGFloat)y {
  
  UIColor *aColor;
  
  // Now your rawData contains the image data in the RGBA8888 pixel format.
  NSInteger byteIndex = (_bytesPerRow * y) + x * _bytesPerPixel;
  // Get color values to construct a UIColor
  CGFloat red   = (_rawData[byteIndex]     * 1.0) / 255.0;
  CGFloat green = (_rawData[byteIndex + 1] * 1.0) / 255.0;
  CGFloat blue  = (_rawData[byteIndex + 2] * 1.0) / 255.0;
  CGFloat alpha = (_rawData[byteIndex + 3] * 1.0) / 255.0;
  
  aColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
  
  return aColor;
}

- (void)setPixel:(CGFloat)x andY:(CGFloat)y replacement:(UIColor *)replacement {
  
  // Now your rawData contains the image data in the RGBA8888 pixel format.
  NSInteger byteIndex = (_bytesPerRow * y) + x * _bytesPerPixel;
  
  // Get color values to construct a UIColor
  CGFloat red   = 0;
  CGFloat green = 0;
  CGFloat blue  = 0;
  CGFloat alpha = 0;
  
  //[replacement getRed:&red green:&green blue:&blue alpha:&alpha];
  
  // Do not use the getRed method on UIColors as it is not backwards compatible.
  const CGFloat* rgb = CGColorGetComponents([replacement CGColor]);
  red = rgb[0];
  green = rgb[1];
  blue = rgb[2];
  alpha = CGColorGetAlpha([replacement CGColor]);
  
  _rawData[byteIndex] = (char) (red * 255);
  _rawData[byteIndex+1] = (char) (green * 255);
  _rawData[byteIndex+2] = (char) (blue * 255);
  _rawData[byteIndex+3] = (char) (alpha * 255);
}

- (void)releasePixelData {
  free(_rawData);
}

@end
