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
@synthesize wallId, linkedUrl, httpRequest;

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

- (void) viewDidLoad {
	if (linkedUrl == nil) {
		wallId.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultWallId"];
	} else {
		[self handleOpenURL: linkedUrl];
	}
	[linkedUrl release];
}

- (void)dealloc {
	[self.gawkNow release];
	[httpRequest setDelegate:nil];
	[httpRequest setUploadProgressDelegate:nil];
	[httpRequest cancel];
	[httpRequest release];
	[responseArea release];
    [super dealloc];
}

-(void)cameraViewControllerDidCancel {
	
}

-(void)cameraViewControllerFinishedRecording:(NSString *)outputFileURL {
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://staging.gawkwall.com/api/?Action=MobileUpload"]];
	[httpRequest setPostValue:wallId.text forKey:@"WallId"];
	[httpRequest setPostValue:@"iphone" forKey:@"SourceDevice"];
	[httpRequest setPostValue:@"true" forKey:@"Debug"];
	[httpRequest setPostValue:@"true" forKey:@"photo"];
	[httpRequest setFile:outputFileURL forKey:@"photo"];
	[httpRequest setTimeOutSeconds:20];
	[httpRequest setUploadProgressDelegate:progressIndicator];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(uploadFailed:)];
	[httpRequest setDidFinishSelector:@selector(uploadFinished:)];
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
}

@end