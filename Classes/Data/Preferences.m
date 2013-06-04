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

#import "Preferences.h"

@implementation Preferences

+ (void)setPreferenceInt:(NSString *)key value:(NSInteger)value {
  // Set value
  [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
  // Commit the preferences.
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setPreferenceBool:(NSString *)key value:(BOOL)value {
  // Set value
  [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
  // Commit the preferences.
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)getPreferenceInt:(NSString *)key
                 defaultValue:(NSInteger)defaultValue {
  
  NSObject *num = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  
  // If the preference exists...
  if (num != nil) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
  }
  else {
    return defaultValue;
  }
}

+ (NSInteger)getPreferenceBool:(NSString *)key defaultValue:(BOOL)defaultValue {
  
  NSObject *num = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  
  // If the preference exists...
  if (num != nil) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
  }
  else {
    return defaultValue;
  }
}

@end
