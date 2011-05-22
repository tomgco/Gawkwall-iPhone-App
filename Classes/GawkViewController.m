////
//  GawkViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import "GawkViewController.h"
#import "CameraViewController.h"
#import "ASIFormDataRequest.h"
#import "GawkAppDelegate.h"
#import "AlbumViewController.h"
#import "JSON.h"

@interface GawkViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)request;
- (void)uploadFinished:(ASIHTTPRequest *)request;
- (void)uploadStarted;
- (void)subscribeFailed:(ASIHTTPRequest *)request;
@end

@implementation GawkViewController

@synthesize gawkNow;
@synthesize videoMaximumDuration;
@synthesize videoQuality;
@synthesize responseArea;
@synthesize wallId, linkedUrl, httpRequest, gawkOutput, email, member;
@synthesize submittingIndicator, activityTitle, activityView, activityMessage, resubmitButton, album, lastGawk, wallCreate;


- (BOOL)validateEmail: (NSString *) candidate {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	
	return [emailTest evaluateWithObject:candidate];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSString *emailXml= [NSString stringWithFormat:@"<save><game>FutureOfWebDesign2011GawkBooth</game><data>%@</data></save>", email.text]; 
		
		[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
		httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:CLOCK_GAMING_API_LOCATION]];
		[httpRequest setPostBody:[NSMutableData dataWithData:[emailXml dataUsingEncoding:NSUTF8StringEncoding]]];
		[httpRequest setTimeOutSeconds:20];
		[httpRequest setUploadProgressDelegate:progressIndicator];	
		[httpRequest setDelegate:self];
		[httpRequest setDidFailSelector:@selector(subscribeFailed:)];
		[httpRequest startAsynchronous];
		email.text = @"";
	}
}

- (void)subscribeEmail:(NSString *)emailAddress {
	if (![emailAddress isEqualToString:@""]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Competition Entry"
																												message:@"By continuing you are entering and accepting the Gawkwall competition terms and conditions."
																											 delegate:self
																							cancelButtonTitle:@"Agree"
																							otherButtonTitles:@"Cancel", nil];
		[alertView show];
		[alertView release];
	}
}

- (IBAction)showCreateWall {
	wallCreate = [[WallCreateViewController alloc] initWithNibName:@"WallCreateViewController" bundle:nil];
	[createWallData addSubview:wallCreate.view];
	//Move to present modal view to manage view from within createWalldata
	//[self presentModalViewController: wallCreate animated:YES];
	[UIView transitionFromView:self.view toView:createWallView duration:0.75 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

-(IBAction)hideCreateWall {
	[UIView transitionFromView:createWallView toView:self.view duration:0.75 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL success) {
		[wallCreate release];
	}];	
}

- (IBAction)showAlbums {
	album = [[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil];
	[albumdata addSubview:album.view];
	[UIView transitionFromView:self.view toView:albumView duration:0.75 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

-(IBAction)hideAlbums {
	[UIView transitionFromView:albumView toView:self.view duration:0.75 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL success) {
		[album release];
	}];	
}


- (void)subscribeFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	[responseArea setText:[error localizedDescription]];
	[self showFailedUpload:[error localizedDescription]];
}

- (IBAction)getVideo {
	if (true) {
		activityView.hidden = TRUE;
		[self hideActivityView];
		CameraViewController *camera = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
		[camera setDelegate:self];
		[email resignFirstResponder];
		[self presentModalViewController: camera animated:YES];
		[camera release];
	} else {
		[self showValidationError:@"Email not valid"];
	}
}

-(IBAction)logoutOfFacebookAndGawk {
	[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) logout];
}

- (NSDictionary *)getMember {
	return [[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member];
}

- (IBAction)resubmitGawk {
	[self startGawkRequest:lastGawk];
	[self toggleActivity];
}

- (void)handleOpenURL:(NSURL *)url {
	NSArray *urlParts = [url pathComponents];
	if ([[url host] isEqualToString:@"wall"] && [urlParts count] > 1) {
		wallId.text = [urlParts objectAtIndex:1];
		linkedUrl = url;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)toggleActivity {
	resubmitButton.hidden = !resubmitButton.hidden;
	submittingIndicator.hidden = !submittingIndicator.hidden;
}

- (void)hideActivityView {
	[self doSlideAnimation:activityView duration:0.2 curve:UIViewAnimationCurveEaseOut x:0.0f y:0.0f];
	resubmitButton.hidden = TRUE;
	submittingIndicator.hidden = FALSE;
}

- (void)cameraViewControllerDidCancel {
	
}

-(void)cameraViewControllerFinishedRecording:(NSString *)outputFileURL withThumbnail:(CGImageRef)tmpImageRef {
	[self uploadGawkVideo:outputFileURL withThumbnail:tmpImageRef];
}

-(void)doSlideAnimation:(UIView *)viewName duration:(NSTimeInterval)duration curve:(int)curve x:(int)x y:(int)y   {
	[UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve: curve];
  [UIView setAnimationBeginsFromCurrentState:YES];
	
  // The transform matrix
  CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
  viewName.transform = transform;
	
  // Commit the changes
  [UIView commitAnimations];
}

- (NSString *)sha1File:(NSString *)fileLocation {
	NSData *data = [NSData dataWithContentsOfFile:fileLocation];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, data.length, digest);
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}

#pragma mark Video Upload

- (void)uploadGawkVideo:(NSString *)fileLocation withThumbnail:(CGImageRef)tmpImageRef{
	activityView.hidden = NO;
	activityTitle.text = @"Sending Data...";
	activityMessage.text = @"";
	[self doSlideAnimation:activityView duration:0.2 curve:UIViewAnimationCurveEaseOut x:0.0f y:70.0f];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"Gawks"];
	NSString *insPath = [NSString stringWithFormat:@"gawk-video-%u.mov", [[NSDate date] timeIntervalSince1970]];
	NSString *destPath = [folderPath stringByAppendingPathComponent:insPath];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager moveItemAtPath:fileLocation toPath:destPath error:nil];
	lastGawk = [[NSString alloc] initWithString:destPath];
	UIImage *tempImage = [UIImage imageWithCGImage:tmpImageRef];
	NSString *jpgPath = [NSString stringWithFormat:@"gawk-image-%u.jpg", [[NSDate date] timeIntervalSince1970]];
	NSString *imageDest = [folderPath stringByAppendingPathComponent:jpgPath];
	[UIImageJPEGRepresentation(tempImage, 90) writeToFile:imageDest atomically:YES];
	[fileManager release];
	
	NSArray *keys = [NSArray arrayWithObjects:@"GawkUrl", @"Thumbnail", @"DateCreated", nil];
	
	NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
	
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd/MM/yyyy"];
	
	[dataItems addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithString:destPath], [NSString stringWithString:imageDest], [dateFormat stringFromDate:today],nil] forKeys:keys]];
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setObject:dataItems forKey:@"Rows"];
	[dateFormat release];
	[data writeToFile:[folderPath stringByAppendingPathComponent:@"Data.plist"] atomically:YES];
	[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] resetData:data];
	[dataItems release];
	[data release];
	[self startGawkRequest:destPath];
}

-(void)startGawkRequest:(NSString*)fileLocation {
	NSString *output = [self sha1File:fileLocation];
	NSString *videoJSON = [NSString stringWithFormat:@"{\"memberSecureId\": \"%@\",\"wallSecureId\" : \"%@\", \"uploadSource\" : \"iphone\", \"approved\" : true, \"rating\" : 0, \"hash\": \"%@\" }", [member objectForKey:@"secureId"], wallId.text, output];
	
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	gawkOutput = [[NSURL alloc] initWithString:fileLocation];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:@"Video.Save" forKey:@"Action"];
	[httpRequest setPostValue:[member objectForKey:@"token"] forKey:@"Token"];
	[httpRequest setPostValue:videoJSON forKey:@"Video"];
	[httpRequest setFile:fileLocation forKey:@"VideoFile"];
	[httpRequest setTimeOutSeconds:5];
	[httpRequest setUploadProgressDelegate:progressIndicator];	
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
	//[responseArea setText:responseData];
	NSLog(@"%@", [responseData description]);
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		[self hideActivityView];
	} else {
		[self uploadFailed:request];
	}
	[parser release];
	[gawkOutput release];
}

	//if connection failed
	//TODO: Store video and wait for device to get a connection
- (void)uploadFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	//[responseArea setText:[error localizedDescription]];
	NSLog(@"%@", [error description]);
	[self showFailedUpload:[error localizedDescription]];
}

- (void)showFailedUpload:(NSString *)errorMessage {
	if (errorMessage == nil)
			errorMessage = @"Unknown Error Occured";
	
	activityTitle.text = @"Ooops! Cannot Gawk at the moment.";
	activityMessage.text = errorMessage;
	[self toggleActivity];
}

#pragma mark Default

- (void) viewDidLoad {
	if (linkedUrl == nil) {
		//wallId.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultWallId"];
	} else {
		[self handleOpenURL: linkedUrl];
	}
	[linkedUrl release];
	//Set Failed Upload view behind UINavigation
	CGPoint cord = [activityView center];
	//[UIScreen mainScreen] bounds].size.height;
	cord.y = 0.0f;
	[activityView setCenter:cord];
	activityView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
}

- (void)viewWillAppear:(BOOL)animated {	
	CGRect frame = self.view.frame;
	frame.origin.y = 20.0;
	self.view.frame = frame;
	albumView.frame = frame;
	createWallView.frame = frame;
}

-(void) viewDidAppear:(BOOL)animated {
	member = [self getMember];
	if ([(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] isOffline]) {
		user.text = @"Hello, you are currently in offline mode. Some features are disabled and your gawk's will be saved in the album to send later.";
	} else {
		user.text = [NSString stringWithFormat:@"Hello, %@", [member objectForKey:@"alias"]];
	}
}

- (void)dealloc {
	[activityView release];
	[activityTitle release];
	[activityMessage release];
	[submittingIndicator release];
	[resubmitButton release];
	
	gawkOutput = nil;
	[gawkOutput release];
	[httpRequest setDelegate:nil];
	[httpRequest setUploadProgressDelegate:nil];
	[httpRequest cancel];
	[httpRequest release];
	[responseArea release];
	[lastGawk release];
	[super dealloc];
}

- (void)showValidationError:(NSString *)msg {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error"
																											message:msg
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];  
}

@end