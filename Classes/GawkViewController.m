//
//  GawkViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import "GawkViewController.h"
#import "CameraViewController.h"
#import "ASIFormDataRequest.h"

@interface GawkViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)request;
- (void)uploadFinished:(ASIHTTPRequest *)request;
@end

@implementation GawkViewController

@synthesize gawkNow;
@synthesize videoMaximumDuration;
@synthesize videoQuality;
@synthesize responseArea;
@synthesize wallId, linkedUrl, httpRequest, gawkOutput;
@synthesize submittingIndicator, activityTitle, activityView, activityMessage, resubmitButton;

- (IBAction)getVideo {
	CameraViewController *camera = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
	[camera setDelegate:self];
	[wallId resignFirstResponder];
	[self presentModalViewController: camera animated:YES];
}

- (IBAction)resubmitGawk {
	NSLog(@"Resubmitting");
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

- (void)cameraViewControllerDidCancel {
	
}

-(void)cameraViewControllerFinishedRecording:(NSString *)outputFileURL {
	[self uploadGawkVideo:outputFileURL];
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

#pragma mark Video Upload

- (void)uploadGawkVideo:(NSString *)fileLocation {
	activityView.hidden = NO;
	[self toggleActivity];
	activityTitle.text = @"Uploading Gawk...";
	activityMessage.text = @"";
	[self doSlideAnimation:activityView duration:0.2 curve:UIViewAnimationCurveEaseOut x:0.0f y:70.0f];
	
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	gawkOutput = [[NSURL alloc] initWithString:fileLocation];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://staging.gawkwall.com/api/?Action=MobileUpload"]];
	[httpRequest setPostValue:wallId.text forKey:@"WallId"];
	[httpRequest setPostValue:@"iphone" forKey:@"SourceDevice"];
	[httpRequest setPostValue:@"true" forKey:@"Debug"];
	[httpRequest setPostValue:@"true" forKey:@"photo"];
	[httpRequest setFile:fileLocation forKey:@"photo"];
	[httpRequest setTimeOutSeconds:20];
	[httpRequest setUploadProgressDelegate:progressIndicator];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(uploadFailed:)];
	//TODO: Move to correct selector
	[httpRequest setDidFinishSelector:@selector(uploadFinished:)];
	//Testing Failed upload.
	//[httpRequest setDidFinishSelector:@selector(uploadFailed:)];
	[httpRequest startAsynchronous];
}

	//After File has been sent to server
- (void)uploadFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	[responseArea setText:responseData];
	[gawkOutput release];
}

	//if connection failed
	//TODO: Store video and wait for device to get a connection
- (void)uploadFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	[self showFailedUpload:[error localizedDescription]];
}

- (void)showFailedUpload:(NSString *)errorMessage {
	if (errorMessage == nil)
			errorMessage = @"Unknown Error Occured";
	
	activityTitle.text = @"Ooops! Cannot Gawk at the moment.";
	activityMessage.text = errorMessage;
	[self toggleActivity];
	//[self doSlideAnimation:activityView duration:0.5 curve:UIViewAnimationCurveEaseOut x:0.0f y:70.0f];
}

#pragma mark Default

- (void) viewDidLoad {
	if (linkedUrl == nil) {
		wallId.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultWallId"];
	} else {
		[self handleOpenURL: linkedUrl];
	}
	[linkedUrl release];
	//Set Failed Upload view behind UINavigation
	CGPoint cord = [activityView center];
	cord.y = 0.0f;
	[activityView setCenter:cord];
	activityView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
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
	[super dealloc];
}

@end


