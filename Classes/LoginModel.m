//
//  LoginModel.m
//  Gawk
//
//  Created by Tom Gallacher on 07/03/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "LoginModel.h"
#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "JSON.h"

@interface LoginModel ()
- (void)loginFailed:(ASIHTTPRequest *)request;
- (void)loginFinished:(ASIHTTPRequest *)request;
- (void)loginStarted;
- (void)registerFailed:(ASIHTTPRequest *)request;
- (void)registerFinished:(ASIHTTPRequest *)request;
@end

@implementation LoginModel

@synthesize httpRequest, facebook, member;
@synthesize delegate = _delegate;

-(id)init {
	self = [super init];
	if (self) {
		member = [[NSMutableDictionary alloc] init];
		facebook = [[Facebook alloc] initWithAppId:GAWK_FACEBOOK_APP_ID];
		facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESS_TOKEN_KEY];
		facebook.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:FB_EXPIRATION_DATE_KEY];
		if ([facebook isSessionValid]) {
			[self gawkFBLogin];
		}
	}
	return self;
}

- (BOOL)validFBSession {
	if ([facebook isSessionValid]) {
		return YES;
	}
	return NO;
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
	NSMutableString *stringValue =	[NSMutableString stringWithCapacity:byteLength * 2];
	NSInteger i;
	for (i = 0; i < byteLength; i++) {
		[stringValue appendFormat:@"%02x", result[i]];
	}
	return stringValue;
}

-(void)registerUser:(NSDictionary *)memberToRegister {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	
	[httpRequest setPostValue:[memberToRegister JSONRepresentation] forKey:@"MemberData"];
	[httpRequest setPostValue:@"Member.RegisterMember" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:20];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(registerFailed:)];
	[httpRequest setDidFinishSelector:@selector(registerFinished:)];
	[httpRequest startAsynchronous];
}

- (void)registerFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		NSDictionary *jsonResponse = [responseData JSONValue];
		if (![[jsonResponse objectForKey:@"success"] boolValue]) {
			//[self registerUser:member];
		} else {
			[self saveMemberData:jsonResponse];
			[self onSuccessfulLogin];
		}
	}
	[parser release];
}

-(void)saveMemberData:(NSDictionary *)jsonResponse {
	NSDictionary *memberData = [jsonResponse objectForKey:@"member"];
	[member setValue:[memberData objectForKey:@"token"] forKey:@"token"];
	[member setValue:[memberData objectForKey:@"secureId"] forKey:@"secureId"];
	[member setValue:[memberData objectForKey:@"emailAddress"] forKey:@"emailAddress"];
	[member setValue:[memberData objectForKey:@"facebookId"] forKey:@"facebookId"];
	[member setValue:[memberData objectForKey:@"firstName"] forKey:@"firstName"];
	[member setValue:[memberData objectForKey:@"lastName"] forKey:@"lastName"];
	[member setValue:[memberData objectForKey:@"alias"] forKey:@"alias"];
	[[NSUserDefaults standardUserDefaults] setObject:[memberData objectForKey:@"emailAddress"] forKey:@"gawk_username"];
	[[NSUserDefaults standardUserDefaults] setObject:[memberData objectForKey:@"facebookId"] forKey:GAWK_FACEBOOK_USER_ID];
	[[NSUserDefaults standardUserDefaults] setObject:[memberData objectForKey:@"token"] forKey:@"gawk_token"];
	[[NSUserDefaults standardUserDefaults] setObject:[memberData objectForKey:@"secureId"] forKey:@"gawk_secure_id"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//if connection failed
- (void)registerFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"%@", [error localizedDescription]);
}

- (void)loginRegisteredUser:(NSString *)email: (NSString *)gawkPassword {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:email forKey:@"EmailAddress"];
	[httpRequest setPostValue:gawkPassword forKey:@"Password"];
	[httpRequest setPostValue:@"Member.Login" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:10];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(loginFailed:)];
	[httpRequest setDidFinishSelector:@selector(loginFinished:)];
	[httpRequest setDidStartSelector:@selector(loginStarted)];
	[httpRequest startAsynchronous];
}

//When the login has started
- (void)loginStarted {
}


- (void)loginFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		NSDictionary *jsonResponse = [responseData JSONValue];
		if (![[jsonResponse objectForKey:@"success"] boolValue]) {
			@try {
				NSDictionary *errors = [[NSDictionary alloc] initWithDictionary:[jsonResponse objectForKey:@"errors"]];
				if ([errors count] > 0) {
					NSString *errorMessage = [[[NSString alloc] init] autorelease]; 
					for (id key in errors) {
						errorMessage = [errorMessage stringByAppendingFormat:@"%@\n", [errors objectForKey:key]];
					}
					[self displayErrorMessage:errorMessage];
				}
				[errors release];
			}
			@catch (NSException *exception) {
				
			}
		} else {
			[self saveMemberData:jsonResponse];
			[self onSuccessfulLogin];
		}
		//[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"gawk_username"];
		//[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		[self loginFailed:request];
	}
	[parser release];
}

//if connection failed
- (void)loginFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"%@", [error localizedDescription]);
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLoginFailed)]) {
		[delegate onGawkLoginFailed];
	}
}

/**
 * Called when the user has logged in successfully to facebook.
 */
- (void)fbDidLogin {
	// store the access token and expiration date to the user defaults
	[[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:FB_ACCESS_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:FB_EXPIRATION_DATE_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];

	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLogin)]) {
		[delegate onGawkLogin];
	}
	[self onSuccessfulFacebookLogin];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	[self loginFailed:nil];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	
}

-(BOOL)gawkLoginWithAuthenticatedFBUser:(NSString *)facebookId {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:facebookId forKey:@"FacebookId"];
	[httpRequest setPostValue:GAWK_API_PUBKEY forKey:@"PublicKey"];
	[httpRequest setPostValue:[self generateSignature:facebookId] forKey:@"Signature"];
	[httpRequest setPostValue:@"Member.Login" forKey:@"Action"];
	
	[httpRequest setTimeOutSeconds:10];	
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
}

-(void)onSuccessfulFacebookLogin {
	[facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void)onSuccessfulLogin {
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onGawkLoginComplete)]) {
		[delegate onGawkLoginComplete];
	}
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
    result = [result objectAtIndex:0];
  }
	[member setValue:[result objectForKey:@"email"] forKey:@"emailAddress"];
	[member setValue:[result objectForKey:@"id"] forKey:@"facebookId"];
	[member setValue:[result objectForKey:@"first_name"] forKey:@"firstName"];
	[member setValue:[result objectForKey:@"last_name"] forKey:@"lastName"];
	[member setValue:[result objectForKey:@"name"] forKey:@"alias"];
	[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"email"] forKey:@"gawk_username"];
	[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:GAWK_FACEBOOK_USER_ID];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self gawkLoginWithAuthenticatedFBUser:[result objectForKey:@"id"]];
}

-(void) login {
	[self gawkLoginWithAuthenticatedFBUser:[member objectForKey:@"facebookId"]];
}

-(void)dealloc {
	[member release];
	[facebook release];
	[super dealloc];
}


- (void) displayErrorMessage: (NSString *) errorMessage {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error"
																											message:errorMessage
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

@end
