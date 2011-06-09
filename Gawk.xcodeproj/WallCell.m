//
//  WallCell.m
//  Gawk
//
//  Created by Tom Gallacher on 09/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "WallCell.h"


@implementation WallCell

@synthesize useDarkBackground, name, creator, description;

- (void)setUseDarkBackground:(BOOL)flag {
	if (flag != useDarkBackground || !self.backgroundView)
	{
		useDarkBackground = flag;
		
		NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
		UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
		self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
		self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundView.frame = self.bounds;
	}
}

- (void)dealloc
{	
	[super dealloc];
}

@end