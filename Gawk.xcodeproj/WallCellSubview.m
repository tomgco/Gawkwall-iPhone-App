//
//  WallCellSubview.m
//  Gawk
//
//  Created by Tom Gallacher on 09/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "WallCellSubview.h"


@implementation WallCellSubview

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	
	iconView.backgroundColor = backgroundColor;
	dateLabel.backgroundColor = backgroundColor;
	wallLabel.backgroundColor = backgroundColor;
}

- (void)setIcon:(UIImage *)newIcon
{
	[super setIcon:newIcon];
	iconView.image = newIcon;
}

- (void)setWall:(NSString *)newWall
{
	[super setWall:newWall];
	wallLabel.text = newWall;
}

- (void)setDate:(NSString *)newDate
{
	[super setDate:newDate];
	dateLabel.text = newDate;
}

- (void)dealloc
{
	[iconView release];
	[dateLabel release];
	[wallLabel release];
	
	[super dealloc];
}

@end
