//
//  LoginViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 24/02/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"


@class ASIFormDataRequest;
@interface LoginViewController : UIViewController {
	ASIFormDataRequest *httpRequest;
	IBOutlet UITextField *emailAddress;
	IBOutlet UITextField *password;
	
	IBOutlet UITextField *registerUserName;
	IBOutlet UITextField *registerUserPassword;
	IBOutlet UITextField *registerEmail;
	IBOutlet UIView *registrationView;
}

-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)registerButtonPressed:(id)sender;
-(IBAction)createButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)dismissKeyboard;

- (void)loginRegisteredUser:(NSString *)userName: (NSString *)password;

@property (retain, nonatomic) ASIFormDataRequest *httpRequest;

@end