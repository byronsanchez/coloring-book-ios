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

#import <Foundation/Foundation.h>
#import "PointNode.h"
#import "NSMutableArray+QueueAdditions.h"

@class ColorViewController;

// Class encapsulating the floodfill algorithm task.
@interface LoadViewTask : NSObject {
  
 @private
  
  PointNode *_point;
  UIColor *_target;
  UIColor *_replacementColor;
  UIImage *_image;
  
  // Define an empty list of points to floodfill.
  NSMutableArray *_list;
  NSMutableArray *_strokeList;
  
  // Access the master view controller.
  __unsafe_unretained ColorViewController *_mContext;
  
  // Pixel Data array
  unsigned char *_rawData;
  NSUInteger _bytesPerPixel;
  NSUInteger _bytesPerRow;
  
}

@property(nonatomic, strong) PointNode *point;
@property(nonatomic, strong) UIColor *target;
@property(nonatomic, strong) UIColor *replacementColor;
@property(nonatomic, strong) UIImage *image;

// Constructor that sets the necessary properties for Palette objects.
- (id)initWithContext:(ColorViewController *)colorViewController;

// Starts the task.
- (void)start;

// Runs the main task process.
- (void)run;

// The post-task process on the main thread.
- (void)onPostExecute;

// Runs a typical floodfill algorithm, replacing all pixels of one color
// with another.
- (void)floodFill:(PointNode *)node
      targetColor:(UIColor *)targetColor
 replacementColor:(UIColor *)replacementColor
          picture:(UIImage *)picture;

// Creates a char array containing an image's pixel data.
- (void)generatePixelData:(UIImage *)imageInfo;

// Returns the pixel color at the selected position.
- (UIColor *)getPixel:(CGFloat)x andY:(CGFloat)y;

// Sets a pixel to the specified color.
- (void)setPixel:(CGFloat)x andY:(CGFloat)y replacement:(UIColor *)replacement;

// Frees the pixel image allocation back into the memory pool.
- (void)releasePixelData;

@end
