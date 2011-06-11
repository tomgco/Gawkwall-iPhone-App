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

@interface GawkAppDelegate : NSObject <UIApplicationDelegate, UITabBarDelegate> {
  UIWindow	*window;
	CameraViewController *cameraViewController;
	LoginViewController *loginView;
	GawkViewController *gawkViewController;
	NSMutableDictionary *data;
	NSMutableArray *walls;
	BOOL isOffline;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CameraViewController *cameraViewController;
@property (nonatomic, retain) IBOutlet GawkViewController *gawkViewController;
@property (readonly) LoginViewController *loginView;
@property (nonatomic, retain) NSMutableDictionary *data;
@property (nonatomic, retain) NSMutableArray *walls;
@property (nonatomic) BOOL isOffline;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)showLoginView:(BOOL)animated;
- (IBAction)logout;
-(void) resetData:(NSMutableDictionary*)replaceData;
-(void) updateWalls:(NSArray*)replaceArray;
- (void) saveUserGawks;
-(void)setOnline;
@end

