//
//  AddViewController.m
//  Shopping
//
//  Created by Bill Pringle on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"
#import "ShoppingAppDelegate.h"
#import "Item.h"


@implementation AddViewController

@synthesize path;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"AddView did load");
	
	d = (ShoppingAppDelegate *)
	[[UIApplication sharedApplication] 
	 delegate];

	self.title = @"Shopping Item"; 
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancelClicked:)] autorelease];
	
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(saveClicked:)] autorelease];
	
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(void) cancelClicked:(id)sender {
	NSLog(@"User cancelled edit/add");
	[self.navigationController dismissModalViewControllerAnimated:YES];
	
}

-(void) saveClicked:(id)sender {
	NSLog(@"User Saved edit/add");
	Item *item;
	
	if (!path)
	{ 		item = [[Item alloc] init];
	}
	else 
	{
		item = (Item *)[d.items objectAtIndex:path.row];
	}
	
	item.name = txtName.text;
	item.notes = txtNotes.text;
	NSDecimalNumber *n = [[NSDecimalNumber alloc] initWithString:txtNeed.text];
	item.need = n.intValue;
	[n release];
	
	if (path)
	{
		[d updateItemAtIndexPath:path];
	}
	else {
		// add item to database
		[d insertItem:item];
		[item release];
	}
	
	[d readItems]; // refresh list
	
	
	// dismiss view
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (path)
	{
		Item *item = 
		(Item *)[d.items objectAtIndex:path.row];
		txtName.text = item.name;
		NSDecimalNumber *n = [[NSDecimalNumber alloc] initWithString:txtNeed.text];
		item.need = n.intValue;
		[n release];
		txtNotes.text = item.notes;
	}
	else 
	{
		// clear form
		txtName.text = @"";
		txtNeed.text = @"1";
		txtNotes.text = @"";
		
		[txtName becomeFirstResponder];
	}
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[txtName release];
	[txtNeed release];
	[txtNotes release];
	[d release];
	[path release];

    [super dealloc];
}


@end
