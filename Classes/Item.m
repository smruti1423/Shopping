//
//  Item.m
//  ShoppingList
//
//  Created by Bill Pringle on 1/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Item.h"


@implementation Item

@synthesize itemid, name, notes, need;

-(id)initWithPrimaryKey:(NSInteger) xid {
	[super init];
	itemid = xid;
	name = @"";
	need = 0;
	notes = @"";
	
	return self;
}

-(id)initWithName:(NSString *)n itemid:(NSInteger)i 
			notes:(NSString *)no need:(NSInteger)ne {
	self.itemid = i;
	self.name = n;
	self.need = ne;
	self.notes = no;
	
	return self;
}


@end
