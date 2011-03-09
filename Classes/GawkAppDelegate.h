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

@interface GawkAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow	*window;
  UITabBarController	*tabBarController;
	LoginViewController *loginView;
	CameraViewController *cameraViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet CameraViewController *cameraViewController;
@property (readonly) LoginViewController *loginView;

-(void)showLoginView:(BOOL)animated;

@end

