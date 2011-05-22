//
//  WallCreateModel.h
//  Gawk
//
//  Created by Tom Gallacher on 20/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WallCreateModelDelegate
@required
-(void)onFail: (NSString *)errorMessage;
-(void)onComplete;
@end

@class ASIFormDataRequest;
@interface WallCreateModel : NSObject {
	NSString *url;
	NSString *description;
	NSNumber *publicGawk;
	NSNumber *publicView;
	id <WallCreateModelDelegate> _delegate;
	
	ASIFormDataRequest *httpRequest;
}

@property(retain) NSString *url;
@property(retain) NSString *name;
@property(retain) NSString *description;
@property(retain) NSNumber *publicView;
@property(retain) NSNumber *publicGawk;
@property (nonatomic,assign) id <WallCreateModelDelegate> delegate;
//[NSNumber numberWithBool:YES];

- (void) createWall;
- (NSDictionary*) getMember;

@end
