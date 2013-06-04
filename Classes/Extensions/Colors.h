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

// Static class providing an API for color methods.
@interface Colors : NSObject

// Returns a UIColor based on the hexadecimal representation of that color.
+ (UIColor *)colorFromHexString:(NSString *)hexString;

// Returns the pixel color at the selected position.
+ (NSArray *)getRGBAsFromImage:(UIImage *)imageInfo
                           atX:(CGFloat)x
                          andY:(CGFloat)y
                         count:(NSInteger)count;

@end
