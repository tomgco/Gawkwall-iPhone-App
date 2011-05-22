//
//  WallCreateViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 12/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallCreateModel.h"


@interface WallCreateViewController : UIViewController <UITextFieldDelegate, WallCreateModelDelegate>{
	IBOutlet UITextField *url;
	IBOutlet UITextField *name;
	IBOutlet UISwitch *publicToView;
	IBOutlet UISwitch *friendsCanGawk;
	
	
	WallCreateModel *wallCreateModel;
}

@property(nonatomic, retain) IBOutlet UITextField *url;
@property(nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) WallCreateModel *wallCreateModel;

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)dismissView;
- (IBAction)saveAndCreateWall;
- (void) displayErrorMessage: (NSString *) errorMessage;

@end
