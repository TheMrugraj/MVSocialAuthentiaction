//
//  MVSocialFacebookAuthentication.h
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define kMVFacebookAccessTokenKey @"MVFacebookAccessToken"

@protocol MVFacebookDelegaete<NSObject>

-(void) facebookAuthSucceedWithUserData:(NSDictionary*)userInfo;
-(BOOL) facebookAuthDoneShouldGoForData;
-(void) facebookAuthFailed:(NSError*)error;
-(void) facebookAuthStarted;
-(void) facebookAuthEnded;
@end
@interface MVSocialFacebookAuthentication : NSObject
@property(nonatomic,strong)FBSession*session;
@property(nonatomic,strong)id <MVFacebookDelegaete>delegate;
-(void)authenticateViaFacebook:(id)delegate;
-(void)logOutFromFacebook;
+(id)sharedInstance;
@end
