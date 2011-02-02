//
//  VideoCaptureManager.m
//  Gawk
//
//  Created by Tom Gallacher on 07/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//
#if !TARGET_IPHONE_SIMULATOR
#import "VideoCaptureManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraViewController.h"


@interface VideoCaptureManager ()

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,retain) id deviceConnectedObserver;
@property (nonatomic,retain) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@interface VideoCaptureManager (Internal)

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (NSURL *) tempFileURL:(BOOL)isEncoded;

@end

@implementation VideoCaptureManager

@synthesize session = _session;
@dynamic sessionPreset;
@synthesize videoInput = _videoInput;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize deviceConnectedObserver = _deviceConnectedObserver;
@synthesize deviceDisconnectedObserver = _deviceDisconnectedObserver;
@synthesize backgroundRecordingID = _backgroundRecordingID;
@synthesize delegate = _delegate;
@dynamic recording;

	//Setting up notifications :S
- (id) init {
	self = [super init];
	if (self != nil) {
		void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureSession *session = [self session];
			AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
			
			[session beginConfiguration];
			[session removeInput:[self videoInput]];
			if ([session canAddInput:newVideoInput]) {
				[session addInput:newVideoInput];
			}
			[session commitConfiguration];
			
			[self setVideoInput:newVideoInput];
			[newVideoInput release];
			
			id delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(deviceCountChanged)]) {
				[delegate deviceCountChanged];
			}
			
			if (![session isRunning])
				[session startRunning];
		};
		void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureSession *session = [self session];
			
			[session beginConfiguration];
			
			if (![[[self videoInput] device] isConnected]) {
				[session removeInput:[self videoInput]];				
			}
			
			[session commitConfiguration];
			
			id delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(deviceCountChanged)]) {
				[delegate deviceCountChanged];
			}
			
			if (![session isRunning])
				[session startRunning];
		};
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
		[self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];  
	}
	return self;
}

- (void) dealloc {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:[self deviceConnectedObserver]];
	[notificationCenter removeObserver:[self deviceDisconnectedObserver]];
	[self setDeviceConnectedObserver:nil];
	[self setDeviceDisconnectedObserver:nil];
	
	[[self session] stopRunning];
	[self setSession:nil];
	[self setVideoInput:nil];
	[self setMovieFileOutput:nil];
	[super dealloc];
}

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error {
	BOOL success = NO;
	
	AVCaptureDeviceInput *videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error] autorelease];
	[self setVideoInput:videoInput];
	
	AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
	[self setMovieFileOutput:movieFileOutput];
	[movieFileOutput release];
	
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	if ([session canAddInput:videoInput]) {
		[session addInput:videoInput];
	}
	
	if ([session canAddOutput:movieFileOutput]) {
		[session addOutput:movieFileOutput];
	}
	
	[self setSessionPreset:sessionPreset];
	
	[self setSession:session];
	
	[session release];
	
	success = YES;
	
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(deviceCountChanged)]) {
		[delegate deviceCountChanged];
	}
	
	return success;
}

- (BOOL)isRecording {
	return [[self movieFileOutput] isRecording];
}

- (void)startRecording {
	if ([[UIDevice currentDevice] isMultitaskingSupported]) {
		[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
	}
	AVCaptureConnection *videoConnection = [VideoCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
	if ([videoConnection isVideoOrientationSupported]) {
		//[videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
	}
	[[self movieFileOutput] startRecordingToOutputFileURL:[self tempFileURL:NO] recordingDelegate:self];
	
	[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(stopRecording) userInfo:nil repeats:NO];

}
		 
-(void)stopRecording {
	[[self movieFileOutput] stopRecording];
}

- (NSUInteger) cameraCount
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSString *) sessionPreset
{
	return [[self session] sessionPreset];
}

- (void) setSessionPreset:(NSString *)sessionPreset
{
	AVCaptureSession *session = [self session];
	if (![sessionPreset isEqualToString:[self sessionPreset]] && [session canSetSessionPreset:sessionPreset]) {
		[session beginConfiguration];
		[session setSessionPreset:sessionPreset];
		[session commitConfiguration];
	}
}

- (void) setConnectionWithMediaType:(NSString *)mediaType enabled:(BOOL)enabled;
{
	[[VideoCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]] setEnabled:enabled];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
{
	for (AVCaptureConnection *connection in connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:mediaType]) {
				return [[connection retain] autorelease];
			}
		}
	}
	return nil;
}

@end

@implementation VideoCaptureManager (Internal)

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			return device;
		}
	}
	return nil;
}

- (AVCaptureDevice *)frontFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (NSURL *)tempFileURL:(BOOL)isEncoded
{
	NSString *fileName;
	if (isEncoded) {
		fileName = [[NSString alloc] initWithFormat:@"movie-encoded.mov"];
	} else {
		fileName = [[NSString alloc] initWithFormat:@"movie.mov"];
	}
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), fileName];
	[fileName release];
	NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:outputPath]) {
		NSError *error;
		if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
			id delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(someOtherError:)]) {
				[delegate someOtherError:error];
			}            
		}
	}
	[outputPath release];
	return [outputURL autorelease];
}

@end

@implementation VideoCaptureManager (AVCaptureFileOutputRecordingDelegate)

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(recordingBegan)]) {
		[delegate recordingBegan];
	}
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	id delegate = [self delegate];
	if (error && [delegate respondsToSelector:@selector(someOtherError:)]) {
		[delegate someOtherError:error];
	}
	
	if ([delegate respondsToSelector:@selector(recordingStopped)]) {
		[delegate recordingStopped];
	}
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
	
	AVURLAsset* gawkVideoAsset = [AVURLAsset URLAssetWithURL:outputFileURL options:nil];
	__block AVAssetExportSession* exportedVideoSession = [[AVAssetExportSession alloc] initWithAsset:gawkVideoAsset presetName:AVAssetExportPresetLowQuality];
	NSURL *convertedURL = [self tempFileURL:YES];
	exportedVideoSession.outputURL = convertedURL;
	exportedVideoSession.outputFileType = AVFileTypeQuickTimeMovie;
	[exportedVideoSession exportAsynchronouslyWithCompletionHandler:^(void) {
		
		switch ([exportedVideoSession status]) {
			case AVAssetExportSessionStatusFailed:
				NSLog(@"Export failed: %@", [[exportedVideoSession error] localizedDescription]);
				break;
			case AVAssetExportSessionStatusCompleted:
				if ([delegate respondsToSelector:@selector(recordingFinished:)]) {
					[delegate recordingFinished: convertedURL];
				}
				break;
			default:
				break;
		}
		[exportedVideoSession release];
	}];
	if ([[UIDevice currentDevice] isMultitaskingSupported]) {
		[[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
	}
	[pool release];
}

@end
#endif
