//
//  AlbumViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlbumViewController : UITableViewController {
    NSArray *tableDataSource;
}

@property (nonatomic, retain) NSArray *tableDataSource;

@end
