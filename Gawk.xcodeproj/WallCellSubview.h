//
//  WallCellSubview.h
//  Gawk
//
//  Created by Tom Gallacher on 09/06/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>
#import "WallCell.h"

@interface WallCellSubview : WallCell
{
	IBOutlet UIImageView *iconView;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *wallLabel;
}

@end
