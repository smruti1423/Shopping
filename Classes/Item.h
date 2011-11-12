//
//  Item.h
//  Shopping
//
//  Created by Bill Pringle on 1/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject {
	NSInteger itemid;
	NSString *name;
	NSInteger need;
	NSString *notes;
	
}

@property (nonatomic, readwrite) NSInteger itemid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, readwrite) NSInteger need;
@property (nonatomic, retain) NSString *notes;

-(id)initWithPrimaryKey:(NSInteger) xid;
-(id)initWithName:(NSString *)n itemid:(NSInteger)i 
			notes:(NSString *)no need:(NSInteger)ne;

@end
