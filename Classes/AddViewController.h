//
//  AddViewController.h
//  Shopping
//
//  Created by Bill Pringle on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ShoppingAppDelegate.h"
#import "Item.h"

@interface AddViewController : UIViewController {
	ShoppingAppDelegate *d; // app delegate

	IBOutlet UITextField *txtName;
	IBOutlet UITextView *txtNotes;
	IBOutlet UITextField *txtNeed;
	
	NSIndexPath *path;
}

@property (nonatomic, retain) NSIndexPath *path;

@end
