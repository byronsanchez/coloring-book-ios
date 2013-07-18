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

@class NodeDatabase;

// Class encapsulating the dbupgrade task.
@interface DBUpgradeTask : NSObject {
  
@private
  
  // Access the master view controller.
  __unsafe_unretained NodeDatabase *_mContext;
  UIActivityIndicatorView *_vcIndicator;
  UIAlertView *_alert;
  NSString *_mScriptID;
  
}

// Constructor that sets the necessary data for upgrading.
- (id)initWithContext:(NodeDatabase *)nodeDatabase
             scriptID:(NSString *)scriptID;

// Starts the task.
- (void)execute;

// The pre-task process on the main thread.
- (void)onPreExecute;

// Runs the main task process.
- (void)run;

// The post-task process on the main thread.
- (void)onPostExecute;

@end
