//
//  ShoppingAppDelegate.h
//  Shopping
//
//  Created by Bill Pringle on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <sqlite3.h>
#import "Item.h"

@interface ShoppingAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSString *dbname; // name of database
	NSString *dbpath; // location of database
	sqlite3 *database; // database object
	sqlite3_stmt *selStmt; // compiled SELECT SQL statement
	sqlite3_stmt *updStmt; // compiled UPDATE SQL statement
	sqlite3_stmt *delStmt; // compiled DELETE SQL statement
	sqlite3_stmt *insStmt; // compiled INSERT SQL statement
	
	NSMutableArray *items;  // Array for items in shopping list
	
	BOOL copyDb;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *items;

-(void) openDatabase;
-(BOOL)createDatabase;
-(void) readItems;
-(void) updateItemAtIndexPath:(NSIndexPath *)path;
-(void) deleteItemAtIndexPath:(NSIndexPath *)path;
-(void) insertItem:(Item *)item;
-(void) closeDatabase;

@end

