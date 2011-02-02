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
@synthesize wallId, linkedUrl, httpRequest, gawkOutput, failedUploadView;

- (IBAction)getVideo {
	CameraViewController *camera = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
	[camera setDelegate:self];
	[wallId resignFirstResponder];
	[self presentModalViewController: camera animated:YES];
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

-(void)cameraViewControllerDidCancel {
	
}

-(void)cameraViewControllerFinishedRecording:(NSString *)outputFileURL {
	[self uploadGawkVideo:outputFileURL];
}

#pragma mark Video Upload

- (void)uploadGawkVideo:(NSString *)fileLocation {
	gawkOutput =  [NSURL URLWithString:fileLocation];
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
	//[httpRequest setDidFinishSelector:@selector(uploadFinished:)];
	//Testing Failed upload.
	[httpRequest setDidFinishSelector:@selector(uploadFailed:)];
	[httpRequest startAsynchronous];
}

	//After File has been sent to server
- (void)uploadFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	[responseArea setText:responseData];
	
}

	//if connection failed
	//Possibly store video and wait for device to get a connection
- (void)uploadFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	[responseArea setText:[error localizedDescription]];
	[self showFailedUpload];
}

- (void)showFailedUpload {
	failedUploadView.hidden = NO;
	[UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.5];
  [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
  [UIView setAnimationBeginsFromCurrentState:YES];
	
  // The transform matrix
  CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, 70.0f);
  failedUploadView.transform = transform;
	
  // Commit the changes
  [UIView commitAnimations];
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
	CGPoint cord = [failedUploadView center];
	cord.y = 0.0f;
	[failedUploadView setCenter:cord];
}

- (void)dealloc {
	[failedUploadView release];
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


