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


@interface LoginModel : NSObject <UITextFieldDelegate, FBRequestDelegate,
FBDialogDelegate, FBSessionDelegate> {
	ASIFormDataRequest *httpRequest;
	Facebook *facebook;
}

-(NSString*)generateSignature;
-(BOOL)gawkLoginWithAuthenticatedFBUser:(NSString*)facebookId;
-(void)loginRegisteredUser:(NSString *)userName: (NSString *)password;

@property (retain, nonatomic) ASIFormDataRequest *httpRequest;
@property (nonatomic, retain) Facebook *facebook;

@end
