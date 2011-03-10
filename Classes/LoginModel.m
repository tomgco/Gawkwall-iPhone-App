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
-(NSString*)generateSignature:(NSString *)fbUserId {
	
	typedef struct
	{
    char value[CC_SHA256_DIGEST_LENGTH];
	} HashValueShaHash;
		
	NSString *sig=[[NSString alloc] initWithFormat:@"%@d20533231c09074a07de1cc9f593c1765bdcf146f7efee55abe61e66a2cda80b", fbUserId];
	unsigned char result[20];
	CC_SHA256([sig UTF8String], [sig lengthOfBytesUsingEncoding:NSASCIIStringEncoding],result);
	NSInteger byteLength = sizeof(HashValueShaHash);
	NSMutableString *stringValue =
	[NSMutableString stringWithCapacity:byteLength * 2];
	NSInteger i;
	for (i = 0; i < byteLength; i++) {
		[stringValue appendFormat:@"%02x", result[i]];
	}
	return stringValue;
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
	NSLog(@"%@", responseData);
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		NSDictionary *jsonResponse = [responseData JSONValue];
		NSLog(@"Dictionary value for \"foo\" is \"%@\"", [jsonResponse objectForKey:@"success"]);
		//[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"gawk_username"];
		//[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		NSLog(@"%@", responseData);
		[self loginFailed:request];
	}
	[parser release];
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
	[self onSuccessfulFacebookLogin];
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
	NSLog(@"%@", [self generateSignature:facebookId]);
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:facebookId forKey:@"FacebookId"];
	[httpRequest setPostValue:GAWK_API_PUBKEY forKey:@"PublicKey"];
	[httpRequest setPostValue:[self generateSignature:facebookId] forKey:@"Signature"];
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
	} else {
		[self onSuccessfulFacebookLogin];
	}
	NSLog(@"gawkFBLogin");
}

-(void)logout {
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLogout)]) {
		[delegate onGawkLogout];
	}
}

-(void)onSuccessfulFacebookLogin {
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void)onSuccessfulLogin {
	NSLog(@"gawkonSuccess");
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLogin)]) {
		[delegate onGawkLogin];
	}
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
    result = [result objectAtIndex:0];
  }
	[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"email"] forKey:@"gawk_username"];
	[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:GAWK_FACEBOOK_USER_ID];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self gawkLoginWithAuthenticatedFBUser:[result objectForKey:@"id"]];
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
