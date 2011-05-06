//
//  GawkAppDelegate.h
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;
@class GawkViewController;

@interface GawkAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow	*window;
  UITabBarController	*tabBarController;
	CameraViewController *cameraViewController;
	GawkViewController *gawkViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet CameraViewController *cameraViewController;
@property (nonatomic, retain) IBOutlet GawkViewController *gawkViewController;

- (void)showLoginView:(BOOL)animated;
- (IBAction)logout;

@end

