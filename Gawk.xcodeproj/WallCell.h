//
//  WallCell.h
//  Gawk
//
//  Created by Tom Gallacher on 09/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WallCell : UITableViewCell {
	BOOL useDarkBackground;
	
	NSString *name;
	NSString *creator;
	NSString *description;
}

@property BOOL useDarkBackground;

@property(retain) NSString *name;
@property(retain) NSString *creator;
@property(retain) NSString *description;

@end