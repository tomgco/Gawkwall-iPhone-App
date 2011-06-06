//
//  AlbumVideoViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 02/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlbumVideoViewController : UIViewController {
	IBOutlet UIView *video;
}

- (void) showVideo: (NSURL*)gawkUrl;

@end
