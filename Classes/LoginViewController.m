//
//  LoginViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 24/02/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "GawkAppDelegate.h"

@implementation LoginViewController

@synthesize loginModel;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		loginModel = [[LoginModel alloc] init];
		[loginModel setDelegate:self];
	}
	return self;
}

#pragma View controls

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == emailAddress && [emailAddress.text length] > 0)
		[password becomeFirstResponder];
	if(textField == password && [password.text length] > 0)
		[self loginButtonPressed:textField];
	if(textField == registerUserName && [registerUserName.text length] > 0)
		[registerEmail becomeFirstResponder];
	if(textField == registerEmail && [registerEmail.text length] > 0)
		[registerUserPassword becomeFirstResponder];
	if(textField == registerUserPassword && [registerUserPassword.text length] > 0)
		[registerUserPasswordConfirm becomeFirstResponder];
	if(textField == registerUserPasswordConfirm && [registerUserPasswordConfirm.text length] > 0)
		[self createButtonPressed:textField];
	return NO;
}

-(void)dismissKeyboard {
	[emailAddress resignFirstResponder];
	[password resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
	[emailAddress becomeFirstResponder];
	emailAddress.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"gawk_username"];
	if ([loginModel validFBSession]) {
		[loginModel login];
	}
}

-(IBAction)registerButtonPressed:(id)sender {
	registerUserName.text = @"";
	registerUserPassword.text = @"";
	registerEmail.text = @"";
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	[self.view addSubview:registrationView];
	[UIView commitAnimations];
	[registerUserName becomeFirstResponder];
}

- (BOOL)validateEmail: (NSString *) candidate {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
	return [emailTest evaluateWithObject:candidate];
}

-(IBAction)createButtonPressed:(id)sender {
	if([registerUserName.text length] && [registerUserPassword.text length] && [registerUserPasswordConfirm.text length] && [registerEmail.text length]) {
		NSDictionary *regMember = [[NSDictionary alloc] initWithObjectsAndKeys:registerEmail.text, @"emailAddress",registerUserPassword.text, @"password", registerUserPasswordConfirm.text, @"confirmPassword", registerUserName.text, @"alias",nil];
		[loginModel registerUser:regMember];
		[regMember release];
	} else {
		//throw missing items error
	}	
}

-(IBAction)cancelButtonPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	[registrationView removeFromSuperview];
	[loginView removeFromSuperview];
	[UIView commitAnimations];
}

- (IBAction)showUserPassScreen:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	[self.view addSubview:loginView];
	[UIView commitAnimations];
}

#pragma Standard Login

-(IBAction)loginButtonPressed:(id)sender {
	if([emailAddress.text length] && [password.text length]) {
		emailAddress.enabled = NO;
		password.enabled = NO;
		[loginModel loginRegisteredUser:emailAddress.text :password.text];
	} else {
		//Throw Error message
	}
}

#pragma Facebook Login

-(IBAction)fbLoginButtonPressed:(id)sender {	
	[loginModel gawkFBLogin];
	loading.hidden = NO;
}

- (IBAction) offlineLogin: (id)sender {
	[self dismissModalViewControllerAnimated:YES];
	loading.hidden = YES;
}

-(void)onGawkLogout {
	loading.hidden = YES;
}

-(void)onGawkLoginComplete {
	[self dismissModalViewControllerAnimated:NO];
	loading.hidden = YES;
	[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] setOnline];
}

-(void)onGawkLogin {
	loading.hidden = NO;
}

-(void)onGawkLoginFailed {
	loading.hidden = YES;
}

- (void)dealloc {
	[loginModel release];
	[super dealloc];
}

@end
