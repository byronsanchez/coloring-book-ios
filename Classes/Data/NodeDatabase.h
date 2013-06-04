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
#include <sqlite3.h>

#import "Node.h"
#import "Categorie.h"

// Handles all database requests made by the application.
@interface NodeDatabase : NSObject {
  
 @private
  
  // Define the actual database property.
  sqlite3 *_mOurDatabase;
  NSString *_homeDirectory;
  NSString *_databasePath;
  
  // Define query builder properties.
  NSString *_mLeftOperand;
  NSString *_mRightOperand;
  NSString *_mOperator;
  
}

@property(nonatomic, copy) NSString *homeDirectory;
@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, copy) NSString *mLeftOperand;
@property(nonatomic, copy) NSString *mRightOperand;
@property(nonatomic, copy) NSString *mOperator;


// Wrapper method for creating the database. Intended for external access.
- (void)createDatabase;

// Creates the database or establishes the database connection.
- (void)createDB;

// Checks to see if a database file exists in the default system location.
- (BOOL)DBExists;

// Copies our pre-populated database to the default system database location
// for our application.
- (void)copyDbFromResource;

// Returns the path of the document directory.
- (NSString *)getDocumentDirectory;

// Returns a full list of node titles.
- (NSMutableArray *)getNodeListData;

// Returns a full list of node titles.
- (NSMutableArray *)getNodeListData:(NSInteger)cid;

// Returns a single node row containing all column data.
- (Node *)getNodeData:(NSInteger)l;

// Returns a full list of categories from the categories table.
- (NSMutableArray *)getCategoryListData;

// Updates a node column.
- (void)updateNode:(NSInteger)l
            column:(NSString *)column
             value:(NSInteger)value;

// Updates a category column.
- (void)updateCategory:(NSInteger)l
                column:(NSString *)column
                 value:(NSString *)value;

// Closes the database connection.
- (void)close;

// Sets conditions for a potential WHERE clause.
- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand;

// Sets conditions for a potential WHERE clause.
- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand
       operatorString:(NSString *)operatorString;

// Flushes any query builder properties.
- (void)flushQuery;

@end
