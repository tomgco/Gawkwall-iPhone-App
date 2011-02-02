//
//  GawkViewController.h
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "CameraViewController.h"
@class ASIFormDataRequest;

@interface GawkViewController : UIViewController <UINavigationControllerDelegate, CameraViewControllerDelegate> {
	IBOutlet UIButton *button;
	IBOutlet UITextView *responseArea;
	IBOutlet UITextField *wallId;
	IBOutlet UILabel *failedUploadMessage;
	IBOutlet UIProgressView *progressIndicator;
	IBOutlet UIView *failedUploadView;
	
	UIImagePickerController *gawkNow;
	NSTimeInterval videoMaximumDuration;
	UIImagePickerControllerQualityType videoQuality;
	NSURL	*linkedUrl;
	NSURL *gawkOutput;
	ASIFormDataRequest *httpRequest;

}

- (IBAction)getVideo;
- (void)handleOpenURL:(NSURL *)url;
- (void)uploadGawkVideo:(NSString *)fileLocation;
- (void)showFailedUpload:(NSString *)error;
- (void)doSlideAnimation:(UIView *)viewName duration:(NSTimeInterval)duration curve:(int)curve x:(int)x y:(int)y;

@property (nonatomic, retain) UIImagePickerController *gawkNow;
@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) UIImagePickerControllerQualityType videoQuality;
@property(nonatomic, retain) UITextView *responseArea;
@property(nonatomic, retain) IBOutlet UITextField *wallId;
@property(nonatomic, retain) IBOutlet UILabel *failedUploadMessage;
@property(nonatomic, retain) IBOutlet UIView *failedUploadView;
@property(nonatomic, retain) NSURL *linkedUrl;
@property(nonatomic, retain) NSURL *gawkOutput;
@property (retain, nonatomic) ASIFormDataRequest *httpRequest;
@end

