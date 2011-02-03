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

@implementation GawkAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize cameraViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NSString *version = @"version";
	NSString *currentVersion = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:version];
	if (currentVersion == nil)     // App first run: set up user defaults.
	 {
		[[NSUserDefaults standardUserDefaults] setObject:@"main" forKey:@"defaultWallId"];
		[[NSUserDefaults standardUserDefaults] setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	 }
	
	
		// Add the view controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{

	GawkViewController *gawkController = (GawkViewController *) [tabBarController.viewControllers objectAtIndex:0];
	if (!url) {
		return NO;
	}
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Gawk!" message:@"Launched from Url" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
	[alert show];
	
	[gawkController handleOpenURL:url];
	
	return YES;
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
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
  [tabBarController release];
	[cameraViewController release];
	[window release];
    [super dealloc];
}


@end
