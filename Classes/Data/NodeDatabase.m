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

#import "NodeDatabase.h"

// Define the static constants for the class. Use exterm instead of static for
// public static strings.

// Define the SQLite database location.
static NSString *const DATABASE_NAME = @"coloring_book.db";
static NSString *const DATABASE_PATH = @"Documents";

// Define the tables used in the application.
static NSString *const DATABASE_TABLE_NODE = @"node";
static NSString *const DATABASE_TABLE_CATEGORIES = @"categories";

// Define the "node" table SQLite columns
static NSString *const KEY_NODE_ROWID = @"_id";
static NSString *const KEY_NODE_CATEGORYID = @"cid";
static NSString *const KEY_NODE_TITLE = @"title";
static NSString *const KEY_NODE_BODY = @"body";

// Define the "categories" table SQLite columns
static NSString *const KEY_CATEGORIES_ROWID = @"_id";
static NSString *const KEY_CATEGORIES_CATEGORY = @"category";
static NSString *const KEY_CATEGORIES_DESCRIPTION = @"description";
static NSString *const KEY_CATEGORIES_ISAVAILABLE = @"isAvailable";
static NSString *const KEY_CATEGORIES_SKU = @"sku";

// Define the current schema version.
static NSInteger const SCHEMA_VERSION = 1;


@implementation NodeDatabase

@synthesize homeDirectory = _homeDirectory;
@synthesize databasePath = _databasePath;
@synthesize mLeftOperand = _mLeftOperand;
@synthesize mRightOperand = _mRightOperand;
@synthesize mOperator = _mOperator;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

- (void)createDatabase {
  [self createDB];
}

- (void)createDB {
  // Check to see if the database exists. (Typically, on first run, it
  // should not exist yet).
  BOOL dbExist = [self DBExists];
  
  // If a database does not exist, create one.
  if (!dbExist) {
    
    // Copy our pre-populated database in resources to the writeable Documents
    // directory
    [self copyDbFromResource];
    
  }
  
  // If the database exists, just call it for use.
  
  // Get a readable database for use.
  if (sqlite3_open([_databasePath UTF8String], &_mOurDatabase) != SQLITE_OK) {
    _mOurDatabase = nil;
  }
}

- (BOOL)DBExists {
  
  BOOL fileExists = NO;
  
  // Define a string containing the default system database file path
  // for our application's database.
  // NSString *databasePath = @"";
  _databasePath = [[self getDocumentDirectory] stringByAppendingPathComponent:DATABASE_NAME];
  
  // Open the database.
  fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_databasePath];
  
  // If db is not null, database exists, return true.
  // Else, db does NOT exist, return false.
  return (fileExists) ? YES : NO;
}

- (void)copyDbFromResource {
  
  // Define the file stream.
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Define the error logging property.
  NSError *error = nil;
  
  // Set the source and destination paths for the database copy...
  NSString *dbFilePath = @"";
  NSString *copyDbPath = @"";
  dbFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
  copyDbPath = [[self getDocumentDirectory] stringByAppendingPathComponent:DATABASE_NAME];
  
  // If an error occurs...
  [fileManager copyItemAtPath:dbFilePath toPath:copyDbPath error:&error];
  
  // If an error occurred during copy.
  if (error != nil) {
    [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                message:[error localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"error_ok_label",
                                                          nil)
                      otherButtonTitles:nil] show];
  }
  
  fileManager = nil;
}

- (NSString *)getDocumentDirectory {
  if (_homeDirectory == nil) {
    _homeDirectory = @"";
    _homeDirectory = [NSHomeDirectory() stringByAppendingPathComponent:DATABASE_PATH];
  }
  
  return _homeDirectory;
}

- (NSMutableArray *)getNodeListData {
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_ROWID];
  [columns addObject:KEY_NODE_TITLE];
  [columns addObject:KEY_NODE_BODY];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = @"";
  
  // If the WHERE clause properties were set...
  if (_mLeftOperand != nil && _mRightOperand != nil && _mOperator != nil) {
    // Define the WHERE clause.
    where = [[_mLeftOperand stringByAppendingString:_mOperator] stringByAppendingString:_mRightOperand];
  }
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // ORDER BY
  query = [[[query stringByAppendingString:@" ORDER BY UPPER("] stringByAppendingString:KEY_NODE_TITLE] stringByAppendingString:@")"];
  
  // Declare an array in which to store result data.
  NSMutableArray *retval = [[NSMutableArray alloc] init];
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *titleChars = (char *) sqlite3_column_text(statement, 1);
      char *bodyChars = (char *) sqlite3_column_text(statement, 2);
      
      // Convert the chars to strings.
      NSString *title = [[NSString alloc] initWithUTF8String:titleChars];
      NSString *body = [[NSString alloc] initWithUTF8String:bodyChars];
      
      // Initialize a new object in which to store the data.
      Node *node = [[Node alloc] init];
      
      // Store all the retrieved column data in a Node object.
      node.identifier = identifier;
      node.title = title;
      node.body = body;
      
      // Store the node object in the array.
      [retval addObject:node];
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return retval;
}

- (NSMutableArray *)getNodeListData:(NSInteger)cid {
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_ROWID];
  [columns addObject:KEY_NODE_TITLE];
  [columns addObject:KEY_NODE_BODY];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = @"";
  
  // TODO: Reduce redundancy.
  [self setConditions:KEY_NODE_CATEGORYID
         rightOperand:[NSString stringWithFormat:@"%d", cid]];
  
  // If the WHERE clause properties were set...
  if (_mLeftOperand != nil && _mRightOperand != nil && _mOperator != nil) {
    // Define the WHERE clause.
    where = [[_mLeftOperand stringByAppendingString:_mOperator] stringByAppendingString:_mRightOperand];
  }
  
  [self flushQuery];
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // ORDER BY
  query = [[[query stringByAppendingString:@" ORDER BY "] stringByAppendingString:KEY_NODE_ROWID] stringByAppendingString:@" ASC"];
  
  // Declare an array in which to store result data.
  NSMutableArray *retval = [[NSMutableArray alloc] init];
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *titleChars = (char *) sqlite3_column_text(statement, 1);
      char *bodyChars = (char *) sqlite3_column_text(statement, 2);
      
      // Convert the chars to strings.
      NSString *title = [[NSString alloc] initWithUTF8String:titleChars];
      NSString *body = [[NSString alloc] initWithUTF8String:bodyChars];
      
      // Initialize a new object in which to store the data.
      Node *node = [[Node alloc] init];
      
      // Store all the retrieved column data in a Node object.
      node.identifier = identifier;
      node.title = title;
      node.body = body;
      
      // Store the node object in the array.
      [retval addObject:node];
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return retval;
}

- (Node *)getNodeData:(NSInteger)l {
  
  // Initialize a new object in which to store the data.
  Node *node = [[Node alloc] init];
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_NODE_ROWID];
  [columns addObject:KEY_NODE_TITLE];
  [columns addObject:KEY_NODE_BODY];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = [KEY_NODE_ROWID stringByAppendingString:@" = "];
  // Append the where id.
  
  where = [where stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_NODE];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *titleChars = (char *) sqlite3_column_text(statement, 1);
      char *bodyChars = (char *) sqlite3_column_text(statement, 2);
      
      // Convert the chars to strings.
      NSString *title = [[NSString alloc] initWithUTF8String:titleChars];
      NSString *body = [[NSString alloc] initWithUTF8String:bodyChars];
      
      // Store all the retrieved column data in a Node object.
      node.identifier = identifier;
      node.title = title;
      node.body = body;
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return node;
}

- (NSMutableArray *)getCategoryListData {
  
  // Define an array of columns to SELECT.
  NSMutableArray *columns = [[NSMutableArray alloc] init];
  [columns addObject:KEY_CATEGORIES_ROWID];
  [columns addObject:KEY_CATEGORIES_CATEGORY];
  [columns addObject:KEY_CATEGORIES_DESCRIPTION];
  [columns addObject:KEY_CATEGORIES_ISAVAILABLE];
  [columns addObject:KEY_CATEGORIES_SKU];
  
  // Initialize a where string to contain a potential WHERE clause.
  NSString *where = @"";
  
  // If the WHERE clause properties were set...
  if (_mLeftOperand != nil && _mRightOperand != nil && _mOperator != nil) {
    // Define the WHERE clause.
    where = [[_mLeftOperand stringByAppendingString:_mOperator] stringByAppendingString:_mRightOperand];
  }
  
  /**
   * Query Building Phase
   */
  NSString *query = @"SELECT ";
  
  NSString *columnQuery = @"";
  
  // Iterate through the array of columns and append each to the query.
  for (NSInteger i = 0; i < [columns count]; i++) {
    columnQuery = [columnQuery stringByAppendingString:[columns objectAtIndex:i]];
    
    // If the current column isn't the final column, also append a comma.
    if (i < ([columns count] - 1)) {
      columnQuery = [columnQuery stringByAppendingString:@", "];
    }
  }
  
  query = [query stringByAppendingString:columnQuery];
  
  // Append the table to the query.
  query = [[query stringByAppendingString:@" FROM " ] stringByAppendingString:DATABASE_TABLE_CATEGORIES];
  
  // If a WHERE clause was defined.
  if (![where isEqualToString:@""]) {
    
    // Append the clause to the select query with a space in between.
    query = [[query stringByAppendingString:@" WHERE "] stringByAppendingString:where];
  }
  
  // ORDER BY
  query = [[[query stringByAppendingString:@" ORDER BY "] stringByAppendingString:KEY_CATEGORIES_ROWID] stringByAppendingString:@" ASC"];
  
  // Declare an array in which to store result data.
  NSMutableArray *retval = [[NSMutableArray alloc] init];
  // Declare an object to step through the result set.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step through the result set...
    while (sqlite3_step(statement) == SQLITE_ROW) {
      
      // Store each column from the result set in a local variable.
      NSInteger identifier = sqlite3_column_int(statement, 0);
      char *categoryChars = (char *) sqlite3_column_text(statement, 1);
      char *descriptionChars = (char *) sqlite3_column_text(statement, 2);
      NSInteger isAvailable = sqlite3_column_int(statement, 3);
      char *skuChars = (char *) sqlite3_column_text(statement, 4);
      
      // Convert the chars to strings.
      NSString *categoryString = [[NSString alloc] initWithUTF8String:categoryChars];
      NSString *description = [[NSString alloc] initWithUTF8String:descriptionChars];
      NSString *sku = [[NSString alloc] initWithUTF8String:skuChars];
      
      // Initialize a new object in which to store the data.
      Categorie *category = [[Categorie alloc] init];
      
      // Store all the retrieved column data in a Node object.
      category.identifier = identifier;
      category.category = categoryString;
      category.description = description;
      category.isAvailable = isAvailable;
      category.sku = sku;
      
      // Store the node object in the array.
      [retval addObject:category];
    }
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
  
  return retval;
}

- (void)updateNode:(NSInteger)l
            column:(NSString *)column
             value:(NSInteger)value {
  /**
   * Query Building Phase
   */
  NSString *query = @"UPDATE ";
  query = [query stringByAppendingString:DATABASE_TABLE_NODE];
  
  query = [query stringByAppendingString:@" SET "];
  query = [query stringByAppendingString:column];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", value]];
  
  query = [query stringByAppendingString:@" WHERE "];
  query = [query stringByAppendingString:@"_id"];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  // Declare a statement.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step.
    sqlite3_step(statement);
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
}

- (void)updateCategory:(NSInteger)l
                column:(NSString *)column
                 value:(NSString *)value {
  /**
   * Query Building Phase
   */
  NSString *query = @"UPDATE ";
  query = [query stringByAppendingString:DATABASE_TABLE_CATEGORIES];
  
  query = [query stringByAppendingString:@" SET "];
  query = [query stringByAppendingString:column];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:value];
  
  query = [query stringByAppendingString:@" WHERE "];
  query = [query stringByAppendingString:@"_id"];
  query = [query stringByAppendingString:@" = "];
  query = [query stringByAppendingString:[NSString stringWithFormat:@"%d", l]];
  
  // Declare a statement.
  sqlite3_stmt *statement;
  
  // Execute the query. If it runs without error...
  if (sqlite3_prepare_v2(_mOurDatabase,
                         [query UTF8String],
                         -1,
                         &statement,
                         nil)
      == SQLITE_OK) {
    
    // Step.
    sqlite3_step(statement);
    
    // Garbage collect the memory used for running the statement.
    sqlite3_finalize(statement);
  }
}

- (void)close {
  // Close the database connection.
  sqlite3_close(_mOurDatabase);
}

- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand {
  _mLeftOperand = leftOperand;
  _mRightOperand = rightOperand;
  _mOperator = @"=";
}

- (void)setConditions:(NSString *)leftOperand
         rightOperand:(NSString *)rightOperand
       operatorString:(NSString *)operatorString {
  _mLeftOperand = leftOperand;
  _mRightOperand = rightOperand;
  _mOperator = operatorString;
}

- (void)flushQuery {
  _mLeftOperand = nil;
  _mRightOperand = nil;
  _mOperator = nil;
}

@end
