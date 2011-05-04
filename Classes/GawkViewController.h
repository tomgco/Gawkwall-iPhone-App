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
#import <CommonCrypto/CommonDigest.h>
#import "CameraViewController.h"
@class ASIFormDataRequest;

@interface GawkViewController : UIViewController <UINavigationControllerDelegate, CameraViewControllerDelegate> {
	
	IBOutlet UITextView *responseArea;
	IBOutlet UITextField *wallId;
	IBOutlet UITextField *email;
	IBOutlet UIProgressView *progressIndicator;
	
#pragma mark activityView
	IBOutlet UILabel *activityTitle;
	IBOutlet UILabel *activityMessage;
	IBOutlet UIView *activityView;
	IBOutlet UIButton *resubmitButton;
	IBOutlet UIActivityIndicatorView *submittingIndicator;
	
	
	UIImagePickerController *gawkNow;
	NSTimeInterval videoMaximumDuration;
	UIImagePickerControllerQualityType videoQuality;
	NSURL	*linkedUrl;
	NSURL *gawkOutput;
	ASIFormDataRequest *httpRequest;

}

- (IBAction)getVideo;
- (IBAction)resubmitGawk;
- (IBAction)logoutOfFacebookAndGawk;

- (void)toggleActivity;
- (void)hideActivityView;
- (void)handleOpenURL:(NSURL *)url;
- (void)uploadGawkVideo:(NSString *)fileLocation;
- (void)showFailedUpload:(NSString *)error;
- (void)doSlideAnimation:(UIView *)viewName duration:(NSTimeInterval)duration curve:(int)curve x:(int)x y:(int)y;
- (NSString*)sha1File:(NSString *)fileLocation;

@property (nonatomic, retain) UIImagePickerController *gawkNow;
@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) UIImagePickerControllerQualityType videoQuality;
@property(nonatomic, retain) UITextView *responseArea;
@property(nonatomic, retain) IBOutlet UITextField *wallId;
@property(nonatomic, retain) IBOutlet UITextField *email;
@property(nonatomic, retain) NSURL *linkedUrl;
@property(nonatomic, retain) NSURL *gawkOutput;
@property (retain, nonatomic) ASIFormDataRequest *httpRequest;

#pragma mark activityView
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *submittingIndicator;
@property(nonatomic, retain) IBOutlet UILabel *activityMessage;
@property(nonatomic, retain) IBOutlet UILabel *activityTitle;
@property(nonatomic, retain) IBOutlet UIView *activityView;
@property(nonatomic, retain) IBOutlet UIButton *resubmitButton;

@end

