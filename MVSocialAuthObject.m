//
//  MVSocialAuthObject.m
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import "MVSocialAuthObject.h"

static MVSocialAuthObject* _sharedMySingleton = nil;
@implementation MVSocialAuthObject


+(MVSocialAuthObject*)sharedInstance
{
    @synchronized([MVSocialAuthObject class])
    {
        if (!_sharedMySingleton)
            _sharedMySingleton = [[self alloc] init];
        
        return _sharedMySingleton;
    }
    
    return nil;
}

-(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if([GPPURLHandler handleURL:url
              sourceApplication:sourceApplication
                     annotation:annotation]){
        return YES;}
    else if ( [FBAppCall handleOpenURL:url sourceApplication:sourceApplication]){
        return YES;
    }
    else{
        return NO;
    }
}


#pragma mark - Social Calls
-(void)authenticateViaFacebookDelegate:(id<MVSocialDelegates>)delegate{
    
    _facebookDelegate = delegate;
//    [_facebookDelegate authenticationDidStartedWithType:kMVAuthTypeFacebook];
    facebookHandler = [[MVSocialFacebookAuthentication alloc]init];
    [facebookHandler authenticateViaFacebook:self];
}

-(void)authenticateViaTwitterDelegate:(id<MVSocialDelegates>)delegate{
    _twitterDelegate=delegate;
//    [_twitterDelegate authenticationDidStartedWithType:kMVAuthTypeTwitter];
    twitterHandler = [MVTwitterAuthentication sharedInstance];
    [twitterHandler authenticateViaTwitterWithDelegate:self];
}

-(void)authenticateViaGoogleDelegate:(id<MVSocialDelegates>)delegate{
    _googleDelegate=delegate;
//    [_googleDelegate authenticationDidStartedWithType:kMVAuthTypeGoogle];
    googleHandler = [[MVGooglePlusAuthentication alloc]init];
    [googleHandler authenticateViaGoogleWithClientKey:kGoogleClientId delegate:self];
}


#pragma mark - TwitterDelegates
-(void)twitterAuthenticationSucceedWithUserData:(NSDictionary *)userInfo{
    NSLog(@"Twitter UserInfo : %@",userInfo);
    _authType = kMVAuthTypeTwitter;
    _authData = userInfo;
    [_twitterDelegate authenticationDidFinishedWithType:_authType andAccessData:_authData];
}
-(BOOL)twitterAuthenticationDoneShouldGoForData{
    return YES;
}
-(void)twitterAuthenticationEnded{
    [_twitterDelegate authenticationDidEndedIsGoingForUserData:YES withAuthType:kMVAuthTypeTwitter];
}
-(void)twitterAuthenticationFailed:(NSError *)error{
    [_twitterDelegate authenticationDidFailedByType:kMVAuthTypeTwitter withError:error];
}
-(void)twitterAuthenticationFailedAtAccounts{
    [_twitterDelegate authenticationDidFailedByType:kMVAuthTypeTwitter withError:[NSError errorWithDomain:@"Failed Due Account Not setup" code:1024 userInfo:nil]];
}
-(BOOL)twitterauthenticationShouldHandleFallback{
    return YES;
}
-(void)twitterAuthenticationStarted{
    [_twitterDelegate authenticationDidStartedWithType:kMVAuthTypeTwitter];
}

-(NSString *)twitterAuthenticationNeedsConsumerKey{
    return @"Xg3ACDprWAH8loEPjMzRg";
}
-(NSString *)twitterAuthenticationNeedsSecret{
    return @"9LwYDxw1iTc6D9ebHdrYCZrJP4lJhQv5uf4ueiPHvJ0";
}
-(UIViewController *)twitterAuthenticationWillLoadWebViewForController{
    return (UIViewController*)_twitterDelegate;
}


-(void)logOut{
    [[MVSocialFacebookAuthentication sharedInstance]logOutFromFacebook];
    [[MVGooglePlusAuthentication sharedInstance]logoutFromGoogle];
    [[MVTwitterAuthentication sharedInstance]logoutFromTwitter];
}



#pragma mark - Google Delegates
-(void)googleAuthSucceedWithUserData:(NSDictionary *)userInfo{
    NSLog(@"Google UserInfo : %@",userInfo);
    _authType= kMVAuthTypeGoogle;
    _authData = userInfo;
    [_googleDelegate authenticationDidFinishedWithType:_authType andAccessData:_authData];
}
-(BOOL)googleAuthDoneShouldGoForData{
    return YES;
}
-(void)googleAuthEnded{
    [_googleDelegate authenticationDidEndedIsGoingForUserData:YES withAuthType:kMVAuthTypeGoogle];
}
-(void)googleAuthFailed:(NSError *)error{
    [_googleDelegate authenticationDidFailedByType:kMVAuthTypeGoogle withError:error];
}
-(void)googleAuthStarted{
    [_googleDelegate authenticationDidStartedWithType:kMVAuthTypeGoogle];
}



#pragma mark - Facebook Delegate
-(void) facebookAuthSucceedWithUserData:(NSDictionary*)userInfo{
    NSLog(@"FB UserInfo : %@",userInfo);
    _authType = kMVAuthTypeFacebook;
    _authData = userInfo;
    if(_facebookDelegate && [_facebookDelegate respondsToSelector:@selector(authenticationDidFinishedWithType:andAccessData:)])
        [_facebookDelegate authenticationDidFinishedWithType:_authType andAccessData:_authData];
}
-(BOOL) facebookAuthDoneShouldGoForData{
    return YES;
}
-(void) facebookAuthFailed:(NSError*)error{
    if(_facebookDelegate && [_facebookDelegate respondsToSelector:@selector(authenticationDidFailedByType:withError:)])
        [_facebookDelegate authenticationDidFailedByType:kMVAuthTypeFacebook withError:error];
}
-(void) facebookAuthStarted{
    if(_facebookDelegate && [_facebookDelegate respondsToSelector:@selector(authenticationDidStartedWithType:)])
        [_facebookDelegate authenticationDidStartedWithType:kMVAuthTypeFacebook];
}
-(void) facebookAuthEnded{
    if(_facebookDelegate && [_facebookDelegate respondsToSelector:@selector(authenticationDidEndedIsGoingForUserData:withAuthType:)]){
        [_facebookDelegate authenticationDidEndedIsGoingForUserData:YES withAuthType:kMVAuthTypeFacebook];
    }
}



@end
