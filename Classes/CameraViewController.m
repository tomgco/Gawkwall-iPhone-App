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
#import <MediaPlayer/MediaPlayer.h>

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
@synthesize outputFileURL = _outputFileURL;
@synthesize tempImageRef = _tmpImageRef;

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)viewDidLoad {
#if !TARGET_IPHONE_SIMULATOR
	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	NSError *error;
	VideoCaptureManager *captureManager = [[VideoCaptureManager alloc] init];
	if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetLow error:&error]) {
		[self setCaptureManager:captureManager];
		
		AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
		
		CALayer *viewLayer = [cameraView layer];
		[viewLayer setMasksToBounds:YES];
		
		CGRect bounds = [cameraView bounds];
		
		[captureVideoPreviewLayer setFrame:bounds];
		
		if ([captureVideoPreviewLayer isOrientationSupported]) {
			[captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
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

-(void)viewDidAppear:(BOOL)animated {
	[self openShutters];
}


- (void)dealloc {
	[_captureManager release];
	[_videoPreviewView release];
	[_captureVideoPreviewLayer release];
	[_recordButton release];
	[_outputFileURL release];
    [super dealloc];
}

- (IBAction)record:(id)sender {
	[[self recordButton] setEnabled:NO];
	[[self captureManager] startRecording];
}

- (IBAction) dismissModalView {
	[[self recordButton] setEnabled:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveGawk {
	[self dismissModalView];
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(cameraViewControllerFinishedRecording: withThumbnail:)]) {
		[delegate cameraViewControllerFinishedRecording: [_outputFileURL path] withThumbnail:_tmpImageRef];
	}
}

- (IBAction)retakeGawk {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	[self.view addSubview:previewView];
	[previewView removeFromSuperview];
	[UIView commitAnimations];	
	[[self recordButton] setEnabled:YES];
	[self openShutters];
}

- (void) openShutters {
	[UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.15];
  [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
  [UIView setAnimationBeginsFromCurrentState:YES];
	
  // The transform matrix
  CGAffineTransform transformUp = CGAffineTransformMakeTranslation(0.0f, -110.0f);
	CGAffineTransform transformDown = CGAffineTransformMakeTranslation(0.0f, 110.0f);
  shutterUp.transform = transformUp;
	shutterDown.transform = transformDown;
	
  // Commit the changes
  [UIView commitAnimations];
}

- (void) closeShutters {
	[UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.15];
  [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
  [UIView setAnimationBeginsFromCurrentState:YES];
	
  // The transform matrix
  CGAffineTransform transformUp = CGAffineTransformMakeTranslation(0.0f, 0.0f);
	CGAffineTransform transformDown = CGAffineTransformMakeTranslation(0.0f, 0.0f);
  shutterUp.transform = transformUp;
	shutterDown.transform = transformDown;
	
  // Commit the changes
  [UIView commitAnimations];
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

- (void) recordingStopped:(NSURL *)outputFileURL {
	[[self recordButton] setEnabled:NO];
	[self closeShutters];
	processingLabel.hidden = NO;
	processingIndicator.hidden = NO;
}

- (void)recordingFinished:(NSURL *)outputFileURL fullQuality:(NSURL *)outputUrl thumbnail:(CGImageRef)tempImageRef {
	processingLabel.hidden = YES;
	processingIndicator.hidden = YES;
	
	//TODO: Dealloc player.
	_outputFileURL = [[NSURL alloc] initWithString:[outputFileURL path]];
	_tmpImageRef = tempImageRef;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	[self.view addSubview:previewView];
	[UIView commitAnimations];
	
	MPMoviePlayerController *player =	[[MPMoviePlayerController alloc] initWithContentURL: outputUrl];
	NSLog(@"%@", [outputUrl path]);
	player.repeatMode = MPMovieRepeatModeOne;
	player.controlStyle = MPMovieControlStyleNone;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.scalingMode = MPMovieScalingModeAspectFill;
	[player.view setFrame: video.bounds];  // player's frame must match parent's
	[video addSubview: player.view];
	[player play];
}

@end

