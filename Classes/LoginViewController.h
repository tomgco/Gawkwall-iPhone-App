//
//  LoginViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 24/02/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define FB_ACCESS_TOKEN_KEY @"fb_access_token"
#define FB_EXPIRATION_DATE_KEY @"fb_expiration_date"

@class ASIFormDataRequest;

@interface LoginViewController : UIViewController<UITextFieldDelegate, FBRequestDelegate,
FBDialogDelegate, FBSessionDelegate> {
	ASIFormDataRequest *httpRequest;
	Facebook *facebook;
	
	IBOutlet UITextField *emailAddress;
	IBOutlet UITextField *password;
	IBOutlet UITextField *registerUserName;
	IBOutlet UITextField *registerUserPassword;
	IBOutlet UITextField *registerEmail;
	IBOutlet UIView *registrationView;

}

-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)fbLoginButtonPressed:(id)sender;
-(IBAction)registerButtonPressed:(id)sender;
-(IBAction)createButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)dismissKeyboard;

- (void)loginRegisteredUser:(NSString *)userName: (NSString *)password;

@property (retain, nonatomic) ASIFormDataRequest *httpRequest;
@property (nonatomic, retain) Facebook *facebook;

@end

@interface LoginViewBackground : UIImageView {
	IBOutlet LoginViewController *delegate;
}
@end