//
//  ShoppingAppDelegate.m
//  Shopping
//
//  Created by Bill Pringle on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ShoppingAppDelegate.h"
#import "RootViewController.h"

@implementation ShoppingAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize items;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	
	copyDb = TRUE;     
    
    dbname = @"Shopping.sqlite"; // database name
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	dbpath = [path stringByAppendingPathComponent:dbname];
	
	
	database = nil;
	selStmt = nil; 
	updStmt = nil; 
	delStmt = nil; 
	insStmt = nil; 	[self openDatabase]; // open database
	[self readItems]; 		
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
	[self closeDatabase];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[dbname release];
	[dbpath release];
	[items release];
	[navigationController release];
	[window release];
	[super dealloc];
}


/*
 * open database
 * if database doesn't exist, create it
 *
 */
-(void)openDatabase {
	BOOL ok;
	NSError *error;
	items = [[NSMutableArray alloc] init]; // array for items
	
	/*
	 * determine if database exists.
	 * create a file manager object to test existence
	 *
	 */
	NSFileManager *fm = [NSFileManager defaultManager]; // file manager
	ok = [fm fileExistsAtPath:dbpath];
	
	// if database not there, copy from resource to path
	if (!ok)
	{
		if (copyDb)
		{ // copy the database
			// location in resource bundle
			NSString *appPath = [[[NSBundle mainBundle] resourcePath] 
								 stringByAppendingPathComponent:dbname];
			// copy from resource to where it should be
			ok = [fm copyItemAtPath:appPath toPath:dbpath error:&error];
		}
	}
	[fm release];
	
	// open database
	if (sqlite3_open([dbpath UTF8String], &database) != SQLITE_OK)
	{
		sqlite3_close(database); // in case partially opened
		database = nil; // signal open error
	}
	
	if (!copyDb && !ok)
	{ // first time and database not copied
		ok = [self createDatabase]; // create empty database
	}
	
	if (!ok)
	{ // problems creating database
		NSAssert1(0, @"Problem creating database [%@]",
				  [error localizedDescription]);
	}
	
}

/*
 * Create Database
 *
 * This method is called if the database didn't already exist
 * The openDatabase routine creates an empty database if new
 * This method executes the SQL code to create the db tables
 *
 */
-(BOOL)createDatabase {
	BOOL ret;
	int rc;
	// SQL to create new database
	const char *createItemsSQL = 
	"CREATE TABLE 'items' ('id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'name' VARCHAR, 'need' INTEGER DEFAULT 0, 'notes' TEXT)";
	
	sqlite3_stmt *stmt;
	rc = sqlite3_prepare_v2(database, createItemsSQL, -1, &stmt, NULL);
	
	ret = (rc == SQLITE_OK);
	if (ret)
	{ // statement built, execute
		rc = sqlite3_step(stmt);
		ret = (rc == SQLITE_DONE);
	}
	
	sqlite3_finalize(stmt); // free statement
	
	return ret;
}

/*
 * read items from the database and store in itemw
 *
 */
-(void)readItems {
	
	if (!database) return; // earlier problems
	
	// build select statement
	if (!selStmt)
	{
		const char *sql = "SELECT * FROM items order by name asc;";
		if (sqlite3_prepare_v2(database, sql, -1, &selStmt, NULL) != SQLITE_OK)
		{
			selStmt = nil;
		}
	}
	if (!selStmt)
	{
		NSAssert1(0, @"Can't build SQL to read items [%s]", sqlite3_errmsg(database));
	}
	
	// loop reading items from list
	[items removeAllObjects]; // clear list for rebuild
	int ret;
	while ((ret=sqlite3_step(selStmt))==SQLITE_ROW) 
	{ // get the fields from the record set and assign to item
		// primary key
		NSInteger n = sqlite3_column_int(selStmt, 0); 
		Item *item = [[Item alloc] initWithPrimaryKey:n]; // create item
		// item name
		char *s = (char *)sqlite3_column_text(selStmt, 1);
		if (s==NULL) s = "";
		item.name = [NSString stringWithUTF8String:(char *)s];
		// quantity needed
		item.need = sqlite3_column_int(selStmt, 2);
		// noted
		s = (char *)sqlite3_column_text(selStmt, 3);
		if (s==NULL) s = "";
		item.notes = [NSString stringWithUTF8String:(char *)s];
		[items addObject:item]; // add to list
		[item release]; // free item
	}
	sqlite3_reset(selStmt); // reset (unbind) statement
}

-(void)updateItemAtIndexPath:(NSIndexPath *)path {
	Item *i = (Item *)[items objectAtIndex:path.row];
	NSLog(@"update - need=%d", i.need);
	
	int ret;
	
	const char *sql = "update items set name = ?, need = ?, notes = ? where id = ?;";
	
	if (!updStmt)
	{ // build update statement
		if ((ret=sqlite3_prepare_v2(database, sql, -1, &updStmt, NULL))!=SQLITE_OK)
		{
			NSAssert1(0, @"Error building statement to update items [%s]", sqlite3_errmsg(database));
		}
	}
	
	// bind values to statement
	NSString *s = i.name;
	if (s==NULL) s = @"";
	sqlite3_bind_text(updStmt, 1, [s UTF8String], -1, SQLITE_TRANSIENT);
	NSInteger n = i.need;
	sqlite3_bind_int(updStmt, 2, n);
	s = i.notes;
	if (s==NULL) s = @"";
	sqlite3_bind_text(updStmt, 3, [s UTF8String], -1, SQLITE_TRANSIENT);
	n = i.itemid;
	sqlite3_bind_int(updStmt, 4, n);
	
	// now execute sql statement
	if ((ret=sqlite3_step(updStmt)) != SQLITE_DONE)
	{
		NSAssert1(0, @"Error updating values [%s]", sqlite3_errmsg(database));
	}
	
	// now reset bound statement to original state
	sqlite3_reset(updStmt);
	
}

-(void) deleteItemAtIndexPath:(NSIndexPath *)path {
	
	Item *i = (Item *)[items objectAtIndex:path.row];
	NSLog(@"Deleting item [%s]", i.name);
	int ret;
	
	const char *sql = "delete from items where id = ?;";
	
	if (!delStmt)
	{ // build update statement
		if ((ret=sqlite3_prepare_v2(database, sql, -1, &delStmt, NULL))!=SQLITE_OK)
		{
			NSAssert1(0, @"Error building statement to delete items [%s]", sqlite3_errmsg(database));
		}
	}
	
	// bind values to statement
	NSInteger n = i.itemid;
	sqlite3_bind_int(delStmt, 1, n);
	
	// now execute sql statement
	if ((ret=sqlite3_step(delStmt)) != SQLITE_DONE)
	{
		NSAssert1(0, @"Error deleting item [%s]", sqlite3_errmsg(database));
	}
	
	// now reset bound statement to original state
	sqlite3_reset(delStmt);
	
	[items removeObjectAtIndex:path.row]; // remove from table
	
	[self readItems]; // refresh array
}

-(void) insertItem:(Item *)item {
	int ret; // return code
	const char *sql = 
	"insert into items (name, need, notes) values (?,?,?);";
	
	if (!insStmt)
	{ // first insert - build statement
		if ((ret=sqlite3_prepare_v2(database, sql, -1, &insStmt, NULL))!=SQLITE_OK)
		{
			NSAssert1(0, @"Error building statement to insert item [%s]", sqlite3_errmsg(database));
		}
	}
	
	// bind values
	NSString *s = item.name;
	if (s==NULL) s = @"";
	sqlite3_bind_text(insStmt, 1, [s UTF8String], -1, SQLITE_TRANSIENT);
	NSInteger n = item.need;
	sqlite3_bind_int(insStmt, 2, n);
	s = item.notes;
	if (s==NULL) s = @"";
	sqlite3_bind_text(insStmt, 3, [s UTF8String], -1, SQLITE_TRANSIENT);
	
	
	// now execute sql statement
	if ((ret=sqlite3_step(insStmt)) != SQLITE_DONE)
	{
		NSAssert1(0, @"Error inserting item [%s]", sqlite3_errmsg(database));
	}
	
	// now reset bound statement to original state
	sqlite3_reset(insStmt);
	
	[self readItems]; 
}

-(void)closeDatabase {
	sqlite3_finalize(selStmt);
	sqlite3_finalize(updStmt); 
	sqlite3_close(database);
}


@end

