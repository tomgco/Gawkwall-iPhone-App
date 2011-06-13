//
//  SettingsViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 31/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
	IBOutlet UILabel *userName;
	IBOutlet UIImageView *profileImage;
	IBOutlet UILabel *fullName;
	IBOutlet UIButton *url;
	IBOutlet UITextView *description;
}

- (IBAction) gotoLink:(id)sender;

@end
