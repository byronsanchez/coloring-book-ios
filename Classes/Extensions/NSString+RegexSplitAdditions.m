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

#import "NSString+RegexSplitAdditions.h"

@implementation NSString (RegexSplitAdditions)

- (NSArray *)componentsSeparatedByPattern:(NSString *)pattern {
  NSMutableArray *items = [[NSMutableArray alloc] init];
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:pattern
                                options:NSRegularExpressionAnchorsMatchLines
                                error:&error];
  
  NSMutableString *mutableString = [self mutableCopy];
  // keeps track of what has already been added to the result split array.
  NSInteger lastOffset = 0;
  for (NSTextCheckingResult* result in [regex matchesInString:self
                                                      options:0
                                                        range:NSMakeRange(0, [self length])]) {
    NSRange resultRange = [result range];
    NSInteger rangeLength = resultRange.location - lastOffset;
    
    NSString *substring = [mutableString substringWithRange:NSMakeRange(lastOffset, rangeLength)];
    [items addObject:substring];
    lastOffset = resultRange.location + resultRange.length;
  }
  NSArray *array = [items copy];
  return array;
}

@end
