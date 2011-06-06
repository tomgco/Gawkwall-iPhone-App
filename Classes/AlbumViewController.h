//
//  AlbumViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationCell.h"
#import "AlbumVideoViewController.h"

@interface AlbumViewController : UITableViewController {
    NSArray *tableDataSource;
	IBOutlet UIView *videoPlayer;
	IBOutlet UIView *videoView;
	ApplicationCell *tmpCell;
	AlbumVideoViewController *albumVideoView;
}

@property (nonatomic, retain) NSArray *tableDataSource;
@property (nonatomic, retain) AlbumVideoViewController *albumVideoView;
@property (nonatomic, assign) IBOutlet ApplicationCell *tmpCell;

@end
