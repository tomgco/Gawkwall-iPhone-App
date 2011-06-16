//
//  AlbumViewContainer.h
//  Gawk
//
//  Created by Tom Gallacher on 16/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumViewController.h"

@interface AlbumViewContainer : UIViewController {
	IBOutlet UIView *albumView;
	AlbumViewController *album;
}

@property(nonatomic, retain) AlbumViewController *album;

@end
