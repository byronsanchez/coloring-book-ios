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

#import "DBUpgradeTask.h"
#import "NodeDatabase.h"

@implementation DBUpgradeTask

- (id)initWithContext:(NodeDatabase *)nodeDatabase
             scriptID:(NSString *)scriptID
{
  self = [super init];
  if (self) {
    // Initialization code
    _mContext = nodeDatabase;
    _mScriptID = scriptID;
  }
  return self;
}

- (void)execute {
  [self onPreExecute];
  // Initialize the handler
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void) {
    [self run];
    
    // Once the main task is done, run the onPostExecute hook on the
    // main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
      // main task is done. Call onPostExecute on the main thread.
      [self onPostExecute];
    });
  });
}

- (void)onPreExecute {
  _mContext.mIsUpgradeTaskInProgress = YES;
  
  _alert = [[UIAlertView alloc] initWithTitle:@"Updating" message:@"Applying new updates..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
  [_alert show];
  
  if(_alert != nil) {
    _vcIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _vcIndicator.center = CGPointMake(_alert.bounds.size.width / 2, _alert.bounds.size.height - _vcIndicator.bounds.size.height - 6);
    [_vcIndicator startAnimating];
    [_alert addSubview:_vcIndicator];
    [_vcIndicator startAnimating];
  }
}

- (void)run {
  [_mContext runUpdates:_mScriptID];
}

- (void)onPostExecute {
  [_vcIndicator stopAnimating];
  [_alert dismissWithClickedButtonIndex:0 animated:YES];
  _mContext.mIsUpgradeTaskInProgress = NO;
}

@end
