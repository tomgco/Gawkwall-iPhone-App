//
//  LoginViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 24/02/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "Constant.h"

@interface LoginViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)request;
- (void)uploadFinished:(ASIHTTPRequest *)request;
- (void)uploadStarted;
@end

@implementation LoginViewController

@synthesize httpRequest, facebook;

- (void)loginRegisteredUser:(NSString *)email: (NSString *)gawkPassword {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:email forKey:@"EmailAddress"];
	[httpRequest setPostValue:gawkPassword forKey:@"Password"];
	[httpRequest setPostValue:@"Member.Login" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:20];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(uploadFailed:)];
	[httpRequest setDidFinishSelector:@selector(uploadFinished:)];
	[httpRequest setDidStartSelector:@selector(uploadStarted)];
	[httpRequest startAsynchronous];
}

//When the upload has started
- (void)uploadStarted {
	
}

//After File has been sent to server
- (void)uploadFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", responseData);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.view removeFromSuperview];
}

//if connection failed
//TODO: Store video and wait for device to get a connection
- (void)uploadFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"%@", [error localizedDescription]);
}

-(IBAction)onRegisteredUserLogin {
	NSLog(@"Login!");
}

-(void)viewWillAppear:(BOOL)animated {
	emailAddress.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"gawk-user"];
}

-(IBAction)registerButtonPressed:(id)sender {
	registerUserName.text = @"";
	registerUserName.text = @"";
	registerEmail.text = @"";
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	[self.view addSubview:registrationView];
	[UIView commitAnimations];
}
-(void)_registerUser {

}

- (BOOL)validateEmail: (NSString *) candidate {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
	return [emailTest evaluateWithObject:candidate];
}

-(IBAction)createButtonPressed:(id)sender {
	if([registerUserName.text length] && [registerUserPassword.text length] && [registerEmail.text length] && [self validateEmail:registerEmail.text]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		registerEmail.enabled = NO;
		registerUserName.enabled = NO;
		registerUserPassword.enabled = NO;
	} else {
		//throw missing items error
	}	
}
-(IBAction)cancelButtonPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
	[registrationView removeFromSuperview];
	[UIView commitAnimations];
}

-(IBAction)loginButtonPressed:(id)sender {
	if([emailAddress.text length] && [password.text length]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		emailAddress.enabled = NO;
		password.enabled = NO;
		[self loginRegisteredUser:emailAddress.text :password.text];
	} else {
		//Throw Error message
	}
}

-(IBAction)fbLoginButtonPressed:(id)sender {
	// on login, use the stored access token and see if it still works
	facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESS_TOKEN_KEY];
	facebook.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:FB_EXPIRATION_DATE_KEY];
	
	// only authorize if the access token isn't valid
	// if it *is* valid, no need to authenticate. just move on
	if (![facebook isSessionValid]) {
		NSArray* permissions =  [[NSArray arrayWithObjects:
															@"email", @"offline_access", nil] retain];
		[facebook authorize:permissions delegate:self];
		[permissions release];
	} else {
		NSLog(@"Restored Session");
	}
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	// store the access token and expiration date to the user defaults
	[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:FB_ACCESS_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:FB_EXPIRATION_DATE_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
  NSLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
  NSLog(@"Dis log out");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == emailAddress && [password.text length] > 0)
		[password becomeFirstResponder];
	if(textField == password && [password.text length] > 0)
		[self loginButtonPressed:textField];
	if(textField == registerUserName && [registerUserName.text length] > 0)
		[registerUserPassword becomeFirstResponder];
	if(textField == registerUserPassword && [registerUserPassword.text length] > 0)
		[registerEmail becomeFirstResponder];
	if(textField == registerEmail && [registerEmail.text length] > 0)
		[self createButtonPressed:textField];
	return NO;
}
-(void)dismissKeyboard {
	[emailAddress resignFirstResponder];
	[password resignFirstResponder];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	facebook = [[Facebook alloc] initWithAppId:GAWK_FACEBOOK_ID];
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[httpRequest setDelegate:nil];
	[httpRequest setUploadProgressDelegate:nil];
	[httpRequest cancel];
	[httpRequest release];
	[facebook release];
    [super dealloc];
}


@end

@implementation LoginViewBackground
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate dismissKeyboard];
}

@end
