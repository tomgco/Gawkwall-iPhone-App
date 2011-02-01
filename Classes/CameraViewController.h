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
- (void) cameraViewControllerFinishedRecording:(NSString *)outputURL;
- (void) cameraViewControllerDidCancel;
@end

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate> {
	IBOutlet UIButton *button;
	VideoCaptureManager *_captureManager;
	AVCaptureVideoPreviewLayer *_videoPreviewView;
	AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
	UIBarButtonItem *_recordButton;
	id <CameraViewControllerDelegate> _delegate;
}

@property (nonatomic,retain) VideoCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet AVCaptureVideoPreviewLayer *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic,assign) id <CameraViewControllerDelegate> delegate;

- (IBAction)record:(id)sender;
- (IBAction) dismissModalView;
@end
