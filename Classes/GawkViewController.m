////
//  GawkViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import "GawkViewController.h"
#import "CameraViewController.h"
#import "ASIFormDataRequest.h"
#import "GawkAppDelegate.h"
#import "AlbumViewController.h"
#import "JSON.h"
#import "WallViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface GawkViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)request;
- (void)uploadFinished:(ASIHTTPRequest *)request;
- (void)uploadStarted;
- (void)subscribeFailed:(ASIHTTPRequest *)request;
@end

@implementation GawkViewController

@synthesize gawkNow;
@synthesize videoMaximumDuration;
@synthesize videoQuality;
@synthesize responseArea;
@synthesize wallId, linkedUrl, httpRequest, gawkOutput, email, member;
@synthesize submittingIndicator, activityTitle, activityView, activityMessage, resubmitButton, album, lastGawk, wallCreate, wallView, lastGawkWall, lastGawkWallName;

- (IBAction)showCreateWall {
	wallCreate = [[WallCreateViewController alloc] initWithNibName:@"WallCreateViewController" bundle:nil];
	[self presentModalViewController: wallCreate animated:YES];
}

- (IBAction)showAlbums {
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	
	NSURL *gawkPath = [[NSURL alloc] initWithString:[Path stringByAppendingPathComponent:@"stitch.mp4"]];
	MPMoviePlayerViewController *player =	[[MPMoviePlayerViewController alloc] initWithContentURL: gawkPath];
	player.moviePlayer.repeatMode = MPMovieRepeatModeOne;
	[self presentMoviePlayerViewControllerAnimated:player];
	[gawkPath release];
}



- (void)subscribeFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	[responseArea setText:[error localizedDescription]];
	[self showFailedUpload:[error localizedDescription]];
}

- (IBAction)getVideo {
	if (true) {
		activityView.hidden = TRUE;
		[self hideActivityView];
		CameraViewController *camera = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
		[camera setDelegate:self];
		[email resignFirstResponder];
		[self presentModalViewController: camera animated:YES];
		[camera release];
	} else {
		[self showValidationError:@"Email not valid"];
	}
}

-(IBAction)logoutOfFacebookAndGawk {
	[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) logout];
}

- (NSDictionary *)getMember {
	return [[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member];
}

- (IBAction)resubmitGawk {
	[self startGawkRequest:lastGawk :lastGawkWall];
	[self toggleActivity];
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

- (void)toggleActivity {
	resubmitButton.hidden = !resubmitButton.hidden;
	submittingIndicator.hidden = !submittingIndicator.hidden;
}

- (void)hideActivityView {
	[self doSlideAnimation:activityView duration:0.2 curve:UIViewAnimationCurveEaseOut x:0.0f y:0.0f];
	resubmitButton.hidden = TRUE;
	submittingIndicator.hidden = FALSE;
}

- (void)cameraViewControllerDidCancel {
	
}

-(void)cameraViewControllerFinishedRecording:(NSString *)outputFileURL withThumbnail:(CGImageRef)tmpImageRef {
	[self uploadGawkVideo:outputFileURL withThumbnail:tmpImageRef];
}

-(void)doSlideAnimation:(UIView *)viewName duration:(NSTimeInterval)duration curve:(int)curve x:(int)x y:(int)y   {
	[UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve: curve];
  [UIView setAnimationBeginsFromCurrentState:YES];
	
  // The transform matrix
  CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
  viewName.transform = transform;
	
  // Commit the changes
  [UIView commitAnimations];
}

- (NSString *)sha1File:(NSString *)fileLocation {
	NSData *data = [NSData dataWithContentsOfFile:fileLocation];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, data.length, digest);
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}

#pragma mark Video Upload

- (void)uploadGawkVideo:(NSString *)fileLocation withThumbnail:(CGImageRef)tmpImageRef{
	activityView.hidden = NO;
	activityTitle.text = @"Sending Data...";
	activityMessage.text = @"";
	[self doSlideAnimation:activityView duration:0.2 curve:UIViewAnimationCurveEaseOut x:0.0f y:70.0f];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"Gawks"];
	NSString *insPath = [NSString stringWithFormat:@"gawk-video-%u.mov", [[NSDate date] timeIntervalSince1970]];
	NSString *destPath = [folderPath stringByAppendingPathComponent:insPath];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager moveItemAtPath:fileLocation toPath:destPath error:nil];
	lastGawk = [[NSString alloc] initWithString:destPath];
	UIImage *tempImage = [UIImage imageWithCGImage:tmpImageRef];
	NSString *jpgPath = [NSString stringWithFormat:@"gawk-image-%u.jpg", [[NSDate date] timeIntervalSince1970]];
	NSString *imageDest = [folderPath stringByAppendingPathComponent:jpgPath];
	[UIImageJPEGRepresentation(tempImage, 90) writeToFile:imageDest atomically:YES];
	[fileManager release];
	
	NSArray *keys = [NSArray arrayWithObjects:@"GawkUrl", @"Thumbnail", @"DateCreated", @"RelatedWall", @"Fav", nil];
	
	NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
	
	NSDate *today = [NSDate date];
	NSDateFormatter *monthDateFormat = [[NSDateFormatter alloc] init];
	[monthDateFormat setDateFormat:@"MMM"];
	NSString *month = [NSString stringWithString:[monthDateFormat stringFromDate:today]];
	[monthDateFormat release];
	
	NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
	[dayFormat setDateFormat:@"d"];
	NSString *day = [NSString stringWithString:[dayFormat stringFromDate:today]];
	[dayFormat release];
	day = [self getOrdinalSuffix:[day intValue]];
	
	NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
	[yearFormat setDateFormat:@"YYYY"];
	NSString *year = [NSString stringWithString:[yearFormat stringFromDate:today]];
	[yearFormat release];

	
	[dataItems addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithString:destPath], [NSString stringWithString:imageDest], [NSString stringWithFormat:@"%@ %@ %@", month, day, year], lastGawkWallName, @"0", nil] forKeys:keys]];
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setObject:dataItems forKey:@"Rows"];
	[data writeToFile:[folderPath stringByAppendingPathComponent:@"Data.plist"] atomically:YES];
	[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] resetData:data];
	[dataItems release];
	[data release];
	[self startGawkRequest:destPath :lastGawkWall];
}

-(void)startGawkRequest:(NSString*)fileLocation: (NSString*)wallSecureId {
	NSString *output = [self sha1File:fileLocation];
	NSString *videoJSON = [NSString stringWithFormat:@"{\"memberSecureId\": \"%@\",\"wallSecureId\" : \"%@\", \"uploadSource\" : \"iphone\", \"approved\" : true, \"rating\" : 0, \"hash\": \"%@\" }", [member objectForKey:@"secureId"], wallSecureId, output];
	
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	gawkOutput = [[NSURL alloc] initWithString:fileLocation];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:@"Video.Save" forKey:@"Action"];
	[httpRequest setPostValue:[member objectForKey:@"token"] forKey:@"Token"];
	[httpRequest setPostValue:videoJSON forKey:@"Video"];
	[httpRequest setFile:fileLocation forKey:@"VideoFile"];
	[httpRequest setTimeOutSeconds:5];
	[httpRequest setUploadProgressDelegate:progressIndicator];	
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(uploadFailed:)];
	[httpRequest setDidFinishSelector:@selector(uploadFinished:)];
	[httpRequest setDidStartSelector:@selector(uploadStarted)];
	[httpRequest startAsynchronous];
}

	//When the upload has started
- (void)uploadStarted {
	
}

	//After File has been sent to server
- (void)uploadFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];

	NSLog(@"%@", [responseData description]);
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		if (![[object objectForKey:@"success"] boolValue]) {
			@try {
				NSArray *errors = [[NSArray alloc] initWithArray:[object objectForKey:@"errors"]];
				NSString *errorMessage = [[[NSString alloc] init] autorelease]; 
				for (id item in errors) {
					errorMessage = [errorMessage stringByAppendingFormat:@"%@\n", item];
				}
				[self showFailedUpload:errorMessage];
				[errors release];
			}
			@catch (NSException *exception) {
				
			}
		} else {
			NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
			
			NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithDictionary:[dataItems objectAtIndex:[dataItems count]-1]];
			[update setValue:[[object objectForKey:@"video"] objectForKey:@"secureId"] forKey:@"secureId"];
			[update setValue:[[object objectForKey:@"video"] objectForKey:@"wallSecureId"] forKey:@"wallSecureId"];
			[dataItems replaceObjectAtIndex:[dataItems count]-1 withObject:update];
			NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
			[data setObject:dataItems forKey:@"Rows"];
			[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] resetData:data];
			[self hideActivityView];
		}
	} else {
		[self uploadFailed:request];
	}
	[parser release];
	[gawkOutput release];
}


- (void)uploadFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	//[responseArea setText:[error localizedDescription]];
	NSLog(@"%@", [error description]);
	[self showFailedUpload:[error localizedDescription]];
}

- (void)showFailedUpload:(NSString *)errorMessage {
	if (errorMessage == nil)
			errorMessage = @"Unknown Error Occured";
	
	activityTitle.text = @"Ooops! Cannot Gawk at the moment.";
	activityMessage.text = errorMessage;
	[self toggleActivity];
}

#pragma mark Default

- (void) viewDidLoad {
	if (linkedUrl == nil) {
		//wallId.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultWallId"];
	} else {
		[self handleOpenURL: linkedUrl];
	}
	[linkedUrl release];
	//Set Failed Upload view behind UINavigation
	CGPoint cord = [activityView center];
	//[UIScreen mainScreen] bounds].size.height;
	cord.y = 0.0f;
	[activityView setCenter:cord];
	activityView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
}

- (void)viewWillAppear:(BOOL)animated {	
	CGRect frame = self.view.frame;
	frame.origin.y = 20.0;
	self.view.frame = frame;
	albumView.frame = frame;
	createWallView.frame = frame;
	wallView = [[WallViewController alloc] initWithNibName:@"WallViewController" bundle:nil];
	[wallView setDelegate:self];
	[wallList addSubview:wallView.view];
}

-(void) viewDidAppear:(BOOL)animated {
	member = [self getMember];
	if ([(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] isOffline]) {
		user.text = @"Hello, you are currently in offline mode. Some features are disabled and your gawk's will be saved in the album to send later.";
	} else {
		user.text = [NSString stringWithFormat:@"Hello, %@", [member objectForKey:@"alias"]];
	}
}

- (void)dealloc {
	[activityView release];
	[activityTitle release];
	[activityMessage release];
	[submittingIndicator release];
	[resubmitButton release];
	
	gawkOutput = nil;
	[gawkOutput release];
	[httpRequest setDelegate:nil];
	[httpRequest setUploadProgressDelegate:nil];
	[httpRequest cancel];
	[httpRequest release];
	[responseArea release];
	[lastGawk release];
	[lastGawkWall release];
	[lastGawkWallName release];
	[super dealloc];
}

- (void)showValidationError:(NSString *)msg {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error"
																											message:msg
																										 delegate:nil
																						cancelButtonTitle:@"Okay"
																						otherButtonTitles:nil];
	[alertView show];
	[alertView release];  
}

- (void) onCellSelect:(NSString *)wallSecureId :(NSString *)wallName{
	lastGawkWall = [[NSString alloc] initWithString:wallSecureId];
	lastGawkWallName = [[NSString alloc] initWithString:wallName];
	[self getVideo];
}

- (NSString*)getOrdinalSuffix: (int)number {
	
	NSArray *suffixLookup = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
	
	if (number % 100 >= 11 && number % 100 <= 13) {
		return [NSString stringWithFormat:@"%d%@", number, @"th"];
	}
	
	return [NSString stringWithFormat:@"%d%@", number, [suffixLookup objectAtIndex:(number % 10)]];
}

@end

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
	UIImage *img  = [UIImage imageNamed: @"menu-bar"];
  [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end