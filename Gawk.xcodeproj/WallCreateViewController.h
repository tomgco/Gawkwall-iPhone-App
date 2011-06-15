//
//  WallCreateViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 12/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallCreateModel.h"


@interface WallCreateViewController : UIViewController <UITextFieldDelegate, WallCreateModelDelegate, UITextViewDelegate>{
	IBOutlet UITextField *url;
	IBOutlet UITextField *name;
	IBOutlet UITextView *description;
	IBOutlet UISwitch *publicToView;
	IBOutlet UISwitch *friendsCanGawk;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *form;
	
	WallCreateModel *wallCreateModel;
}

@property(nonatomic, retain) IBOutlet UITextField *url;
@property(nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) WallCreateModel *wallCreateModel;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void) textViewDidBeginEditing:(UITextView *)textView;
- (IBAction)dismissView;
- (IBAction)saveAndCreateWall;
- (void) displayErrorMessage: (NSString *) errorMessage;
- (IBAction) jumpToDescription;
@end
