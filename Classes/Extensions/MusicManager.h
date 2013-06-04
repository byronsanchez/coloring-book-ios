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
#import <AVFoundation/AVFoundation.h>

#import "Preferences.h"

// Static class providing an API to AVFoundation for playing music and sounds.
@interface MusicManager : NSObject

// Initializes an audio session.
+ (void)constructSession;

// Gets the Music Player Volume Preference.
+ (CGFloat)getMusicVolume;

// Gets the Music Player Status Preference - whether or not music is
// enabled.
+ (BOOL)getMusicStatus;

// Starts playing the music.
+ (void)start:(NSInteger)music;

// Starts playing the music.
+ (void)start:(NSInteger)music force:(BOOL)force;

// Pauses the music.
+ (void)pause;

// Updates the volume based on user preferences.
+ (void)updateVolume;

// Updates the player status based on user preferences.
+ (void)updateStatusFromPrefs;

// Releases the media players when they are not needed.
+ (void)releaseData;

// Objective-C specific setters and getters for publically needed static
// variables.
+ (void)setIsEnabled:(BOOL)isEnabled;
+ (void)setIsManualSound:(BOOL)isManualSound;
+ (BOOL)getIsEnabled;
+ (BOOL)getIsManualSound;
+ (NSInteger)getMusicA;

// Deactivates the audio session.
+ (void)destroySession;

@end
