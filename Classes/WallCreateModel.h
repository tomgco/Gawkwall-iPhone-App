//
//  WallCreateModel.h
//  Gawk
//
//  Created by Tom Gallacher on 20/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIFormDataRequest;
@interface WallCreateModel : NSObject {
	NSString *url;
	NSString *description;
	NSNumber *publicGawk;
	NSNumber *publicView;
	
	ASIFormDataRequest *httpRequest;
}

@property(retain) NSString *url;
@property(retain) NSString *description;
@property(retain) NSNumber *publicView;
@property(retain) NSNumber *publicGawk;
//[NSNumber numberWithBool:YES];

- (void) createWall;

- (NSDictionary*) getMember;
- (void) displayErrorMessage: (NSString *) errorMessage;

@end
