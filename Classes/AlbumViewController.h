//
//  AlbumViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationCell.h"

@interface AlbumViewController : UITableViewController {
    NSArray *tableDataSource;
	IBOutlet UIView *videoPlayer;
	ApplicationCell *tmpCell;
}

@property (nonatomic, retain) NSArray *tableDataSource;
@property (nonatomic, assign) IBOutlet ApplicationCell *tmpCell;

@end
