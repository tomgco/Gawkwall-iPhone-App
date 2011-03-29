//
//  LoginModel.h
//  Gawk
//
//  Created by Tom Gallacher on 07/03/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol LoginDelegate
@required
-(void)onGawkLogout;
-(void)onGawkLogin;
@end

@interface LoginModel : NSObject <UITextFieldDelegate, FBRequestDelegate,
FBDialogDelegate, FBSessionDelegate> {
	ASIFormDataRequest *httpRequest;
	Facebook *facebook;
	NSMutableDictionary *member;
	id <LoginDelegate> _delegate;
}

-(void)saveMemberData:(NSDictionary *)jsonResponse;
-(NSString*)generateSignature:(NSString *)fbUserId;
-(void)registerUser:(NSDictionary *)member;
-(BOOL)gawkLoginWithAuthenticatedFBUser:(NSString*)facebookId;
-(void)loginRegisteredUser:(NSString *)userName: (NSString *)password;
-(void)gawkFBLogin;
-(void)onSuccessfulLogin;
-(void)onSuccessfulFacebookLogin;

@property (retain, nonatomic) ASIFormDataRequest *httpRequest;
@property (readonly) Facebook *facebook;
@property (retain, nonatomic) NSMutableDictionary *member;
@property (nonatomic,assign) id <LoginDelegate> delegate;

@end
