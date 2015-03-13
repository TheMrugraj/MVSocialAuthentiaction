//
//  MVGooglePlusAuthentication.h
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
@protocol MVGooglePlusDelegate

#define kMVGoogleAccessTokenKey @"MVGoogleAccessToken"

-(void) googleAuthSucceedWithUserData:(NSDictionary*)userInfo;
-(BOOL) googleAuthDoneShouldGoForData;
-(void) googleAuthFailed:(NSError*)error;
-(void) googleAuthStarted;
-(void) googleAuthEnded;

@end
@interface MVGooglePlusAuthentication : NSObject<GPPSignInDelegate>
@property(nonatomic,strong)NSDictionary *aceessTokenInfo;
@property(nonatomic,strong)NSString *clientId;
@property(nonatomic,strong)id<MVGooglePlusDelegate>googleDelegate;
@property(nonatomic,strong)NSMutableDictionary *userInfo;


+(id)sharedInstance;
-(void)authenticateViaGoogleWithClientKey:(NSString*)clientId delegate:(id<MVGooglePlusDelegate>)delegate;
-(void)logoutFromGoogle;
@end
