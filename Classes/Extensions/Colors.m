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
// Copyright (c) 2011 Dave DeLong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "Colors.h"

@implementation Colors

+ (UIColor *)colorFromHexString:(NSString *)hexString {
  // If the string contains hashes, remove them.
  NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#"
                                                               withString:@""];
  
  // If the hex code is a shortened hex code.
  if ([cleanString length] == 3) {
    // Expand it to a 6-digit hex.
    cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                   [cleanString substringWithRange:NSMakeRange(0, 1)],
                   [cleanString substringWithRange:NSMakeRange(0, 1)],
                   [cleanString substringWithRange:NSMakeRange(1, 1)],
                   [cleanString substringWithRange:NSMakeRange(1, 1)],
                   [cleanString substringWithRange:NSMakeRange(2, 1)],
                   [cleanString substringWithRange:NSMakeRange(2, 1)]];
  }
  
  unsigned int baseValue;
  [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
  
  CGFloat red = ((baseValue >> 24) & 0xFF) / 255.0f;
  CGFloat green = ((baseValue >> 16) & 0xFF) / 255.0f;
  CGFloat blue = ((baseValue >> 8) & 0xFF) / 255.0f;
  CGFloat alpha = ((baseValue >> 0) & 0xFF) / 255.0f;
  
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSArray *)getRGBAsFromImage:(UIImage *)imageInfo
                           atX:(CGFloat)x
                          andY:(CGFloat)y
                         count:(NSInteger)count {
  
  // An array containing the UIColor of the selected pixels.
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
  
  // imageInfo is now considered the working image for reading/writing pixel
  // data.
  CGImageRef imageRef = [imageInfo CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(height * width * 4,
                                                   sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData,
                                               width,
                                               height,
                                               bitsPerComponent,
                                               bytesPerRow,
                                               colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
  
  
  // Now your rawData contains the image data in the RGBA8888 pixel format.
  NSInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
  for (NSInteger ii = 0 ; ii < count ; ++ii)
  {
    // Get color values to construct a UIColor
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    byteIndex += 4;
    
    UIColor *aColor = [UIColor colorWithRed:red
                                      green:green
                                       blue:blue
                                      alpha:alpha];
    [result addObject:aColor];
  }
  
  free(rawData);
  
  return result;
}

@end
