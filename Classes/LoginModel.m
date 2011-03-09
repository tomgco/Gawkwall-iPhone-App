//
//  LoginModel.m
//  Gawk
//
//  Created by Tom Gallacher on 07/03/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "LoginModel.h"
#import "LoginViewController.h"
#import "Constant.h"
#import <CommonCrypto/CommonDigest.h>
#import "JSON.h"

@interface LoginModel ()
- (void)loginFailed:(ASIHTTPRequest *)request;
- (void)loginFinished:(ASIHTTPRequest *)request;
- (void)loginStarted;
@end

@implementation LoginModel

@synthesize httpRequest, facebook;
@synthesize delegate = _delegate;

-(id)init {
	self = [super init];
	if (self) {
		facebook = [[Facebook alloc] initWithAppId:GAWK_FACEBOOK_APP_ID];
		facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESS_TOKEN_KEY];
		facebook.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:FB_EXPIRATION_DATE_KEY];
	}
	return self;
}

//TODO: Make this function work by combining facebookid with hash below and sha256 it
-(NSString*)generateSignature {
	char input[] = "d20533231c09074a07de1cc9f593c1765bdcf146f7efee55abe61e66a2cda80b";
	unsigned char result[64];
	CC_MD5(input, strlen(input), result);
	return [NSString stringWithUTF8String:(const char *)result];
}

- (void)loginRegisteredUser:(NSString *)email: (NSString *)gawkPassword {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:email forKey:@"EmailAddress"];
	[httpRequest setPostValue:gawkPassword forKey:@"Password"];
	[httpRequest setPostValue:@"Member.Login" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:20];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(loginFailed:)];
	[httpRequest setDidFinishSelector:@selector(loginFinished:)];
	[httpRequest setDidStartSelector:@selector(loginStarted)];
	[httpRequest startAsynchronous];
}

//When the login has started
- (void)loginStarted {
}

//After File has been sent to server
- (void)loginFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		NSDictionary *jsonResponse = [responseData JSONValue];
		NSLog(@"Dictionary value for \"foo\" is \"%@\"", [jsonResponse objectForKey:@"success"]);
		[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"gawk_username"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		NSLog(@"%@", responseData);
		[self loginFailed:request];
	}
	[parser release];
	//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//	[self.view removeFromSuperview];
}

//if connection failed
- (void)loginFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"%@", [error localizedDescription]);
}

/**
 * Called when the user has logged in successfully to facebook.
 */
- (void)fbDidLogin {
	// store the access token and expiration date to the user defaults
	[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:FB_ACCESS_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:FB_EXPIRATION_DATE_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"nom");
	[self onSuccessfulLogin];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
  NSLog(@"not nom");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	NSLog(@"not nom");
}

-(BOOL)gawkLoginWithAuthenticatedFBUser:(NSString *)facebookId {
	
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:GAWK_FACEBOOK_APP_ID forKey:@"FacebookId"];
	[httpRequest setPostValue:GAWK_API_PUBKEY forKey:@"PublicKey"];
	[httpRequest setPostValue:[self generateSignature] forKey:@"Signature"];
	[httpRequest setPostValue:@"Member.Login" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:20];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(loginFailed:)];
	[httpRequest setDidFinishSelector:@selector(loginFinished:)];
	[httpRequest setDidStartSelector:@selector(loginStarted)];
	[httpRequest startAsynchronous];
	
	return YES;
}

-(void)gawkFBLogin {
	if (![facebook isSessionValid]) {
		NSArray* permissions =  [[NSArray arrayWithObjects:
															@"email", @"offline_access", nil] retain];
		[facebook authorize:permissions delegate:self];
		[permissions release];
	}
	NSLog(@"gawkFBLogin");
	[self onSuccessfulLogin];
}

-(void)logout {
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLogout)]) {
		[delegate onGawkLogout];
	}
}

-(void)onSuccessfulLogin {
	NSLog(@"gawkonSuccess");
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLogin)]) {
		[delegate onGawkLogin];
	}
}

-(void)dealloc {
	[httpRequest setDelegate:nil];
	[httpRequest setUploadProgressDelegate:nil];
	[httpRequest cancel];
	[httpRequest release];
	[facebook release];
	[super dealloc];
}

@end
