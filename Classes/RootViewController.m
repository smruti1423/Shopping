//
//  RootViewController.m
//  Shopping
//
//  Created by Bill Pringle on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <sqlite3.h>
#import "RootViewController.h"
#import "ShoppingAppDelegate.h"
#import "Item.h"


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
	av = nil; // no item view yet
	avnav = nil;
	
	
	appDelegate = (ShoppingAppDelegate *)
	[[UIApplication sharedApplication] delegate];
	self.title = @"Shopping List";
	
	addButton = [[UIBarButtonItem alloc]
				 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
				 target:self action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton; 
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	self.tableView.allowsSelectionDuringEditing = true;
}


-(void) addButtonClicked:(id)sender {
	NSLog(@"Add button clicked");
	[self detailView:nil];
}

-(void) detailView:(NSIndexPath *)path {
	if (!av)
	{ 
		av = [[AddViewController alloc]
			  initWithNibName:@"AddViewController" bundle:nil];
	}
	av.path = path;
	if (!avnav)
	{
		avnav = [[UINavigationController alloc]
				 initWithRootViewController:av];
	}
	[self.navigationController 
	 presentModalViewController:avnav 
	 animated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [appDelegate.items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// get the item for this cell
	Item *i = (Item *) [appDelegate.items objectAtIndex:indexPath.row];
	
	if (i.need > 1)
	{
		cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",
							   i.name, i.need];
	}
	else
	{
		cell.textLabel.text = i.name; // display item name in table cell
	}
	cell.detailTextLabel.text = i.notes;
	
	//
	// checkmark if item is needed
	// checkmark will toggle with subsequent selects
	//
	if (i.need>0)
	{ // item needed - display checkmark
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{ // not needed no checkmark
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}




// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	// get the item for this cell
	Item *i = (Item *) [appDelegate.items objectAtIndex:indexPath.row];
	
	// deselect row and toggle selection checkmark
	[tableView deselectRowAtIndexPath:indexPath animated:NO]; // deselect row
	// get selected cell
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (self.editing)
	{
		[self detailView:indexPath];
	}
	else
	{
		//
		// toggle checkmark
		// if need is zero, assume now needed and set to one
		// if need positive, no longer needed - make negative
		// if need negative, still needed - make positive
		NSLog(@"Row %d selected - need=%d",indexPath.row, i.need);
		if (i.need==0)
		{ // item needed - set checkmark
			i.need = 1;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else if (i.need < 0)
		{ // still needed
			i.need = -i.need; // reset original value
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else
		{
			i.need = -i.need;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}		
	}
	NSLog(@"Need is now %d", i.need);
	
	[appDelegate updateItemAtIndexPath:indexPath]; // update database
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (editing)
	{
		self.navigationItem.rightBarButtonItem = nil;
	}
	else
	{
		self.navigationItem.rightBarButtonItem = addButton;
	}
	
	[self.tableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView 
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		[appDelegate deleteItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:
			[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// nothing to do - item already added
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[appDelegate release];
	[av release];
	[avnav release];
    [super dealloc];
}


@end

