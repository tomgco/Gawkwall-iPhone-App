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
#import "AlbumViewController.h"
@class ASIFormDataRequest;

@interface GawkViewController : UIViewController <CameraViewControllerDelegate> {
	
	IBOutlet UITextView *responseArea;
	IBOutlet UITextField *wallId;
	IBOutlet UITextField *email;
	IBOutlet UIProgressView *progressIndicator;
	
#pragma mark activityView
	IBOutlet UILabel *user;
	IBOutlet UILabel *activityTitle;
	IBOutlet UILabel *activityMessage;
	IBOutlet UIView *activityView;
	IBOutlet UIView *albumView;
	IBOutlet UIView *albumdata;
	IBOutlet UIButton *resubmitButton;
	IBOutlet UIActivityIndicatorView *submittingIndicator;
	
	NSDictionary *member;
	NSURL	*linkedUrl;
	NSURL *gawkOutput;
	ASIFormDataRequest *httpRequest;
	AlbumViewController *album;
	NSString *lastGawk;
}

- (IBAction)getVideo;
- (IBAction)showAlbums;
- (IBAction)hideAlbums;
- (IBAction)resubmitGawk;
- (IBAction)logoutOfFacebookAndGawk;

- (void)toggleActivity;
- (NSDictionary*)getMember;
- (void)hideActivityView;
- (void)handleOpenURL:(NSURL *)url;
- (void)uploadGawkVideo:(NSString *)fileLocation withThumbnail:(CGImageRef)tmpImageRef;
- (void)subscribeEmail: (NSString *)emailAddress;
- (void)showFailedUpload:(NSString *)error;
- (void)doSlideAnimation:(UIView *)viewName duration:(NSTimeInterval)duration curve:(int)curve x:(int)x y:(int)y;
- (NSString*)sha1File:(NSString *)fileLocation;
- (BOOL)validateEmail: (NSString *)canidate;
- (void)showValidationError: (NSString *)msg;
- (void)startGawkRequest:(NSString*)fileLocation;

@property (nonatomic, retain) UIImagePickerController *gawkNow;
@property (nonatomic, retain) NSDictionary *member;
@property(nonatomic) NSTimeInterval videoMaximumDuration;
@property(nonatomic) UIImagePickerControllerQualityType videoQuality;
@property(nonatomic, retain) UITextView *responseArea;
@property(nonatomic, retain) IBOutlet UITextField *wallId;
@property(nonatomic, retain) IBOutlet UITextField *email;
@property(nonatomic, retain) NSURL *linkedUrl;
@property(nonatomic, retain) NSURL *gawkOutput;
@property(nonatomic, retain) NSString *lastGawk;
@property (retain, nonatomic) ASIFormDataRequest *httpRequest;
@property (retain, nonatomic) AlbumViewController *album;

#pragma mark activityView
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *submittingIndicator;
@property(nonatomic, retain) IBOutlet UILabel *activityMessage;
@property(nonatomic, retain) IBOutlet UILabel *activityTitle;
@property(nonatomic, retain) IBOutlet UIView *activityView;
@property(nonatomic, retain) IBOutlet UIButton *resubmitButton;

@end

