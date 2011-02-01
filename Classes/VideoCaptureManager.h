//
//  VideoCaptureManager.h
//  Gawk
//
//  Created by Tom Gallacher on 07/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoCaptureManagerDelegate
@optional
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;
- (void) cannotWriteToAssetLibrary;
- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL;
- (void) someOtherError:(NSError *)error;
- (void) recordingBegan;
- (void) recordingStopped;
- (void) recordingFinished:(NSURL *)outputFileURL;
- (void) deviceCountChanged;
@end

@interface VideoCaptureManager : NSObject {
	AVCaptureSession *_session;
	AVCaptureVideoOrientation _orientation;
		//AVCamMirroringMode _mirroringMode;
	
	AVCaptureDeviceInput	*_videoInput;
	AVCaptureMovieFileOutput *_movieFileOutput;
	
		//Crazy notification stuff which i do not know that much of.
	
	id _deviceConnectedObserver;
	id _deviceDisconnectedObserver;
	
		//Background completion
	UIBackgroundTaskIdentifier _backgroundRecordingID;
	
		// Capture Manager delegate
	id <VideoCaptureManagerDelegate> _delegate;
}

@property (nonatomic,readonly,retain) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,assign) NSString *sessionPreset;
@property (nonatomic,readonly,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,readonly,retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,assign) id <VideoCaptureManagerDelegate> delegate;
@property (nonatomic,readonly,getter=isRecording) BOOL recording;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (void) startRecording;
- (void) stopRecording;
	//- (BOOL) cameraToggle;
- (NSUInteger) cameraCount;
	//- (void) focusAtPoint:(CGPoint)point;
	//- (void) exposureAtPoint:(CGPoint)point;
- (void) setConnectionWithMediaType:(NSString *)mediaType enabled:(BOOL)enabled;
	//- (BOOL) supportsMirroring;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
