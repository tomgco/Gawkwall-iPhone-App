//
//  LoginViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 24/02/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoginModel.h"
#import "FBConnect.h"

@class ASIFormDataRequest;

@interface LoginViewController : UIViewController<UITextFieldDelegate, LoginDelegate> {	
	IBOutlet UITextField *emailAddress;
	IBOutlet UITextField *password;
	IBOutlet UITextField *registerUserName;
	IBOutlet UITextField *registerUserPassword;
	IBOutlet UITextField *registerEmail;
	IBOutlet UIView *registrationView;
	
	LoginModel *loginModel;

}

-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)fbLoginButtonPressed:(id)sender;
-(IBAction)registerButtonPressed:(id)sender;
-(IBAction)createButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)dismissKeyboard;

@property (nonatomic, retain) LoginModel *loginModel;

@end

@interface LoginViewBackground : UIImageView {
	IBOutlet LoginViewController *delegate;
}
@end