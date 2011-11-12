//
//  RootViewController.h
//  Shopping
//
//  Created by Bill Pringle on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AddViewController.h"
#import "ShoppingAppDelegate.h"

@interface RootViewController : UITableViewController {
	UIBarButtonItem *addButton;
	ShoppingAppDelegate *appDelegate;
	AddViewController *av; // add view
	UINavigationController *avnav; // add view navigation controller
}

@end
