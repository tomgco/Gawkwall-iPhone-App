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
	
	UIImage *icon;
	NSString *wall;
	NSString *date;
}

@property BOOL useDarkBackground;

@property(retain) UIImage *icon;
@property(retain) NSString *wall;
@property(retain) NSString *date;

@end