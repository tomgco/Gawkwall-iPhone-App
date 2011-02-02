//	This is the Gawk in progress view. 
//
//  CameraViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 07/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import "CameraViewController.h"
#import "VideoCaptureManager.h"
#import <AVFoundation/AVFoundation.h>

#if !TARGET_IPHONE_SIMULATOR
@interface CameraViewController (VideoCaptureManagerDelegate) <VideoCaptureManagerDelegate>
@end
#endif

@implementation CameraViewController

@synthesize recordButton = _recordButton;
@synthesize videoPreviewView = _videoPreviewView;
@synthesize captureManager = _captureManager;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;
@synthesize delegate = _delegate;

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[_captureManager release];
	[_videoPreviewView release];
	[_captureVideoPreviewLayer release];
	[_recordButton release];
    [super viewDidUnload];
}

-(void)viewDidLoad {
#if !TARGET_IPHONE_SIMULATOR
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	NSError *error;
	VideoCaptureManager *captureManager = [[VideoCaptureManager alloc] init];
	if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetLow error:&error]) {
		[self setCaptureManager:captureManager];
		
		AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
		UIView *view = [self view];
		CALayer *viewLayer = [view layer];
		[viewLayer setMasksToBounds:YES];
		
		CGRect bounds = [view bounds];
		
		[captureVideoPreviewLayer setFrame:bounds];
		
		if ([captureVideoPreviewLayer isOrientationSupported]) {
			//[captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
		}
		
		[captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		
		[[captureManager session] startRunning];
		
		[self setCaptureVideoPreviewLayer:captureVideoPreviewLayer];
		
		if ([[captureManager session] isRunning]) {
			//[captureManager setOrientation:AVCaptureVideoOrientationPortrait];
			[captureManager setDelegate:self];
			[viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[captureVideoPreviewLayer release];
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
																													message:@"Failed to start session."
																												 delegate:nil
																								cancelButtonTitle:@"Okay"
																								otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
	} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Device Init Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
	}
	
	[captureManager release];
#endif
	[super viewDidLoad];
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)record:(id)sender {
	[[self recordButton] setEnabled:NO];
	[[self captureManager] startRecording];
}

- (IBAction) dismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}


@end

@implementation CameraViewController (VideoCaptureManagerDelegate)

- (void) cannotWriteToAssetLibrary
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incompatible with Asset Library"
																											message:@"The captured file cannot be written to the asset library. It is likely an audio-only file."
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];        
}

- (void) acquiringDeviceLockFailedWithError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Configuration Lock Failure"
																											message:[error localizedDescription]
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];    
}

- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Asset Library Error"
																											message:[error localizedDescription]
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];    
}

- (void) someOtherError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																											message:[error localizedDescription]
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];    
}

- (void) recordingBegan {
	[[self recordButton] setEnabled:NO];
}

- (void) recordingStopped {
	[self dismissModalView];
	[[self recordButton] setTitle:@"Record"];
	[[self recordButton] setEnabled:YES];
}

- (void)recordingFinished:(NSURL *)outputFileURL {
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(cameraViewControllerFinishedRecording:)]) {
		[delegate cameraViewControllerFinishedRecording: [outputFileURL path]];
	}
}

@end

