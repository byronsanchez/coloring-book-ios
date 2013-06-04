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

#import "MusicManager.h"

// Define a boolean for determining whether or not the user has enabled the
// Media Player via preferences.
static BOOL sIsEnabled = NO; //
static BOOL sIsManualSound = NO; //
static BOOL sIsSessionConstructed = NO;

// Define a flag for signaling previous music for music switches.
static NSInteger const MUSIC_PREVIOUS = -1;
// Define integer ids for each music type.
static NSInteger const MUSIC_A = 0; //

// Define a hash map in which to store the media players corresponding to
// each song (useful for multiple song management).
static NSMutableDictionary *sPlayers;
// Define current and previous music statuses as nil to start off with.
static NSInteger sCurrentMusic = -1;
static NSInteger sPreviousMusic = -1;

// Define the audio session.
static AVAudioSession *sSession = nil;

@implementation MusicManager

+ (void)constructSession {
  
  // If the session has not yet been configured...
  if (sSession == nil) {
    // Implicitly initialize the audio session.
    sSession = [AVAudioSession sharedInstance];
  }
  
  // Activate the audio session.
  NSError *activationError = nil;
  BOOL activationSuccess = [sSession setActive:YES error:&activationError];
  
  if (!activationSuccess) {
    // Output a message.
    [[[UIAlertView alloc] initWithTitle:[activationError localizedDescription]
                                message:[activationError localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
    
    // Signal the failure and exit.
    sIsSessionConstructed = NO;
    return;
  }
  
  // Configure the audio session.
  NSError *setCategoryError = nil;
  BOOL setCategorySuccess = [sSession setCategory:AVAudioSessionCategoryAmbient
                                            error:&setCategoryError];
  
  if (!setCategorySuccess) {
    // Output a message.
    [[[UIAlertView alloc] initWithTitle:[setCategoryError localizedDescription]
                                message:[setCategoryError localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
    
    // Signal the failure and exit.
    sIsSessionConstructed = NO;
    return;
  }
  
  // If we made it this far, the audio session was configured with no problems!
  // Signal the success!
  sIsSessionConstructed = YES;
  
  // Allocate space for the mPlayer dictionary if it hasn't been done yet.
  if (sPlayers == nil) {
    sPlayers = [[NSMutableDictionary alloc] init];
  }
}

+ (CGFloat)getMusicVolume {
  // Get the preference as an int.
  CGFloat volumeInt = [Preferences getPreferenceInt:@"sbSettingsMusicVolume"
                                         defaultValue:1.0];
  
  // return the value
  return volumeInt;
}

+ (BOOL)getMusicStatus {
  // Get the preference as a boolean.
  BOOL volumeBool = [Preferences getPreferenceBool:@"tbSettingsMusicIsChecked"
                                      defaultValue:NO];
  
  // return the boolean value
  return volumeBool;
}

+ (void)start:(NSInteger)music {
  [self start:music force:NO];
}

+ (void)start:(NSInteger)music force:(BOOL)force {
  
  // If the media player is NOT enabled, return. No music will play.
  // Start and stop of currently playing music should be handled in the
  // user input activity, so functionality can be tailored to the activity.
  if (!sIsEnabled) {
    return;
  }
  
  // If a song is currently playing and a force hasn't been requested...
  if (!force && sCurrentMusic > -1) {
    // return and end the function. No need to start the new song.
    return;
  }
  // ???
  if (music == MUSIC_PREVIOUS) {
    music = sPreviousMusic;
  }
  // If the requested song is the currently playing song...
  if (music == sCurrentMusic) {
    // return, as the song is already playing.
    return;
  }
  // If a song is currently playing.
  if (sCurrentMusic != -1) {
    // Then since it got this far, a force must have been requested.
    
    // Set the previous music id to the currently playing music id.
    sPreviousMusic = sCurrentMusic;
    // Pause the currently playing music to get ready for a song change.
    [self pause];
  }
  
  /**
   * Construct the audio session.
   */
  [self constructSession];
  
  // If the session was not constructed, end the start request.
  if (!sIsSessionConstructed) {
    return;
  }
  
  /**
   * Configure the audio player.
   */
  
  // Set the current music id to the requested music id.
  sCurrentMusic = music;
  
  // Key value must be an object.
  NSString *keyValue = [NSString stringWithFormat:@"%d", music];
  
  // Get the media players for the requested music from the HashMap.
  AVAudioPlayer *mp = [sPlayers objectForKey:keyValue];
  
  // If media players for this song exists...
  if (mp != nil) {
    // If the song is currently not playing...
    if (![mp isPlaying]) {
      // Start playing the song.
      [mp play];
    }
  }
  else {
    
    // Else, this is the first time this media player is being created
    // and
    // stored in the HashMap. Create each the media player for the
    // requested
    // song, attach it to its corresponding resource, and store the
    // player in
    // the Hash Map for easy access later.
    
    // Put if, else if cases here; one for each MUSIC_CONSTANT defined
    // above.
    // The code should be roughly the same for each case except for the
    // conditional check and the create method should references the
    // corresponding media resource for that soung
    if (music == MUSIC_A) {
      
      NSError *allocationError = nil;
      
      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"beat_delib_01"
                                                           ofType:@"mp3"];
      
      mp = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                  error:&allocationError];
      
      if (allocationError != nil) {
        [[[UIAlertView alloc] initWithTitle:[allocationError localizedDescription]
                                    message:[allocationError localizedFailureReason]
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                              nil)
                          otherButtonTitles:nil] show];
      }
      
      [mp prepareToPlay];
      
    }
    else {
      // unsupported music number...
      // There's nothing to do with a song that doesn't exist. Return
      // the
      // method.
      return;
    }
    
    // Store the media player in the HashMap, keyed by it's id.
    [sPlayers setValue:mp forKey:keyValue];
    // Get the volume preference.
    CGFloat volume = [self getMusicVolume];
    // Set the music volume on this media player.
    [mp setVolume:volume];
    
    // If the media player was successfully created...
    if (mp != nil) {
      // Enable infinite looping.
      [mp setNumberOfLoops:-1];
      // Start playing the song.
      [mp play];
    }
  }
  
}

+ (void)pause {
  // Iterate through the collection of media players...
  for (NSString *key in sPlayers) {
    // If a media player is playing...
    if ([[sPlayers objectForKey:key] isPlaying]) {
      // pause it.
      [[sPlayers objectForKey:key] pause];
    }
  }
  
  // previousMusic should always be something valid, so check to make sure
  // that currentMusic is not signalling nil.
  if (sCurrentMusic != -1) {
    // Set the previous music id to be the current music id.
    sPreviousMusic = sCurrentMusic;
  }
  
  // Set the current music id flag to signal that there is no current
  // music
  // playing
  sCurrentMusic = -1;
}

+ (void)updateVolume {
  // Get the volume from preferences.
  CGFloat volume = [self getMusicVolume];
  
  // Set the volume for each media player.
  for (NSString *key in sPlayers) {
    if ([sPlayers objectForKey:key] != nil) {
      [[sPlayers objectForKey:key] setVolume:volume];
    }
  }
}

+ (void)updateStatusFromPrefs {
  // Get the volume from preferences.
  BOOL status = [self getMusicStatus];
  sIsEnabled = status;
}

+ (void)releaseData {
  for (NSString *key in sPlayers) {
    
    // If that media player is currently playing...
    if ([[sPlayers objectForKey:key] isPlaying]) {
      // Stop the music...
      [[sPlayers objectForKey:key] stop];
    }
  }
  
  // Clear the collection.
  [sPlayers removeAllObjects];
  // If the current music id is not nil...
  if (sCurrentMusic != -1) {
    // Set the previous music id to the current music id.
    sPreviousMusic = sCurrentMusic;
  }
  
  // Set the current music id to signal nil.
  sCurrentMusic = -1;
}

+ (void)setIsEnabled:(BOOL)isEnabled {
  sIsEnabled = isEnabled;
}

+ (void)setIsManualSound :(BOOL)isManualSound {
  sIsManualSound = isManualSound;
}

+ (BOOL)getIsEnabled {
  return sIsEnabled;
}

+ (BOOL)getIsManualSound {
  return sIsManualSound;
}

+ (NSInteger)getMusicA {
  return MUSIC_A;
}

+ (void)destroySession {
  
  if (sSession != nil) {
    
    // Deactivate the audio session.
    NSError *deactivationError = nil;
    BOOL deactivationSuccess = [sSession setActive:NO error:&deactivationError];
    
    if (!deactivationSuccess) {
      [[[UIAlertView alloc] initWithTitle:[deactivationError localizedDescription]
                                  message:[deactivationError localizedFailureReason]
                                 delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                            nil)
                        otherButtonTitles:nil] show];
    }
  }
  
}

@end
