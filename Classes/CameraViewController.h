//
//  CameraViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 07/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VideoCaptureManager, AVCaptureVideoPreviewLayer;

@protocol CameraViewControllerDelegate <NSObject>
@required
- (void) cameraViewControllerFinishedRecording:(NSString *)outputURL withThumbnail:(CGImageRef)tmpImageRef;
- (void) cameraViewControllerDidCancel;
@end

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate> {
	IBOutlet UIButton *button;
	IBOutlet UIButton *saveButton;
	IBOutlet UIButton *retakeGawk;
	IBOutlet UIView *previewView;
	IBOutlet UIView *video;
	IBOutlet UIView *cameraView;
	IBOutlet UIImageView *shutterUp;
	IBOutlet UIImageView *shutterDown;
	IBOutlet UIActivityIndicatorView *processingIndicator;
	IBOutlet UILabel *processingLabel;
	CGImageRef _tmpImageRef;
	
	VideoCaptureManager *_captureManager;
	AVCaptureVideoPreviewLayer *_videoPreviewView;
	AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
	UIBarButtonItem *_recordButton;
	id <CameraViewControllerDelegate> _delegate;
	NSURL *_outputFileURL;
}

@property (nonatomic) CGImageRef tempImageRef;
@property (nonatomic,retain) VideoCaptureManager *captureManager;
@property (nonatomic,retain) NSURL *outputFileURL;
@property (nonatomic,retain) IBOutlet AVCaptureVideoPreviewLayer *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic,assign) id <CameraViewControllerDelegate> delegate;

- (IBAction)record:(id)sender;
- (IBAction) dismissModalView;
- (IBAction) saveGawk;
- (IBAction) retakeGawk;
- (void) closeShutters;
- (void) openShutters;
@end
