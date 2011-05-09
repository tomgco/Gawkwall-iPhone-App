//
//  GawkAppDelegate.h
//  Gawk
//
//  Created by Tom Gallacher on 01/12/2010.
//  Copyright 2010 Clock Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "LoginModel.h"

@class CameraViewController;
@class GawkViewController;

@interface GawkAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow	*window;
	CameraViewController *cameraViewController;
	LoginViewController *loginView;
	GawkViewController *gawkViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CameraViewController *cameraViewController;
@property (nonatomic, retain) IBOutlet GawkViewController *gawkViewController;
@property (readonly) LoginViewController *loginView;

- (void)showLoginView:(BOOL)animated;
- (IBAction)logout;

@end

