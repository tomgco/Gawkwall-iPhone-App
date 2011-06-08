//
//  AlbumViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AlbumViewController : UITableViewController {
    NSArray *tableDataSource;
	IBOutlet UIView *videoPlayer;
	IBOutlet UIView *videoView;
	ApplicationCell *tmpCell;
	MPMoviePlayerController *player;
	NSUInteger videoId;
}

@property (nonatomic, retain) NSArray *tableDataSource;
@property (nonatomic, assign) IBOutlet ApplicationCell *tmpCell;
@property (nonatomic, retain) MPMoviePlayerController *player;

- (IBAction)backToList;

@end