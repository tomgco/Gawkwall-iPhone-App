//
//  WallViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 23/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WallViewDelegate <NSObject>
@required
-(void)onCellSelect:(NSString*)wallSecureId;
@end

@class ASIFormDataRequest;
@interface WallViewController : UITableViewController {
	ASIFormDataRequest *httpRequest;
	NSArray *wallList;
	id <WallViewDelegate> _delegate;
}

@property(nonatomic, retain) NSArray *wallList;
@property (nonatomic,assign) id <WallViewDelegate> delegate;

@end
