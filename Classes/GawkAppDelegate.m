//
//  GawkAppDelegate.m
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import "GawkAppDelegate.h"
#import "GawkViewController.h"
#import "VideoCaptureManager.h"
#import "CameraViewController.h"
#import "LoginViewController.h"
#import "FBConnect.h"
#import "Constant.h"

@implementation GawkAppDelegate

@synthesize window;
@synthesize cameraViewController;
@synthesize gawkViewController;
@synthesize loginView, data;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"Gawks"];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	//if (![fileManager fileExistsAtPath:folderPath isDirectory:YES]) {
	[fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
	//}
	if (![fileManager fileExistsAtPath:[folderPath stringByAppendingPathComponent:@"Data.plist"]]) {
		[fileManager copyItemAtPath:[Path stringByAppendingPathComponent:@"Data.plist"] toPath:[folderPath stringByAppendingPathComponent:@"Data.plist"] error:nil];
	}
	[fileManager release];
	NSString *DataPath = [folderPath stringByAppendingPathComponent:@"Data.plist"];
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:DataPath];
	self.data = tempDict;
	[tempDict release];
	NSLog(@"%@", self.data);
	
	NSString *version = @"version";
	NSString *currentVersion = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:version];
	if (currentVersion == nil)     // App first run: set up user defaults.
	 {
		[[NSUserDefaults standardUserDefaults] setObject:@"main" forKey:@"defaultWallId"];
		[[NSUserDefaults standardUserDefaults] setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	 }
	
	
		// Add the view controller's view to the window and display.
	self.window.rootViewController = self.gawkViewController;
	[self.window makeKeyAndVisible];
	[self showLoginView:NO];
    return YES;
}

-(void)showLoginView:(BOOL)animated {
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	if(!loginView) {
		loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	}
	
	[gawkViewController presentModalViewController:loginView animated:animated];
	
	//[loginView release];
}

-(void) resetData:(NSMutableDictionary*)replaceData {
	self.data = [[NSMutableDictionary alloc] initWithDictionary:replaceData];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (!url) {
		return NO;
	}
	
	if ([[url scheme] isEqualToString:GAWK_FACEBOOK_FB_URL]) {
		NSLog(@"Loggin");
		return [[[loginView loginModel] facebook] handleOpenURL:url];
	} else {
	
		[gawkViewController handleOpenURL:url];
		
		return YES;
	}
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	if ([[[cameraViewController captureManager] session] isRunning] == NO) {
		[[[cameraViewController captureManager] session] startRunning];
	}   
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

-(IBAction)logout{
	NSLog(@"Logout");
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gawk_username"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:GAWK_FACEBOOK_USER_ID];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_ACCESS_TOKEN_KEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:FB_EXPIRATION_DATE_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[loginView loginModel].facebook.accessToken = nil;
	[loginView loginModel].facebook.expirationDate = nil;
	[self showLoginView:YES];
}


- (void)dealloc {
	[data release];
  [gawkViewController release];
	[cameraViewController release];
	[window release];
    [super dealloc];
}


@end
