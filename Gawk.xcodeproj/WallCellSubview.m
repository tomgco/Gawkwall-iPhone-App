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
	creatorLabel.backgroundColor = backgroundColor;
	nameLabel.backgroundColor = backgroundColor;
}

- (void)setName:(NSString *)newName
{
	[super setName:newName];
	nameLabel.text = newName;
}

- (void)setCreator:(NSString *)newCreator
{
	[super setCreator:newCreator];
	creatorLabel.text = newCreator;
}

- (void)setDescription:(NSString *)newDescription
{
	[super setDescription:newDescription];
	descriptionLabel.text = newDescription;
}

- (void)dealloc
{
	[creatorLabel release];
	[nameLabel release];
	
	[super dealloc];
}

@end
