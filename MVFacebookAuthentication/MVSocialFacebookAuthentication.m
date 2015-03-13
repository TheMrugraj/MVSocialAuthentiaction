//
//  MVSocialFacebookAuthentication.m
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import "MVSocialFacebookAuthentication.h"
static MVSocialFacebookAuthentication *sharedInstance =nil;
@implementation MVSocialFacebookAuthentication

+(MVSocialFacebookAuthentication*)sharedInstance
{
    @synchronized([MVSocialFacebookAuthentication class])
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        
        return sharedInstance;
    }
    
    return nil;
}


-(void)authenticateViaFacebook:(id)delegate{


    _delegate = delegate;
    [_delegate facebookAuthStarted];
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        //Already have Opened Session
        [self sendDataWithSession:[FBSession activeSession]];
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        
        FBSession *session = [[FBSession alloc]init];
        [FBSession setActiveSession:session];
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
        {
            if (session.state == FBSessionStateOpen || session.state == FBSessionStateOpenTokenExtended || session.state==FBSessionStateCreatedTokenLoaded)
            {
                [self sendDataWithSession:session];
                [_delegate facebookAuthEnded];
            }else if(session.state==FBSessionStateClosedLoginFailed){
                [_delegate facebookAuthFailed:error];
            }
        }];
    }
}


-(void)sendDataWithSession:(FBSession*)session{
    _session = session;
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
        if (error) {
            // Handle error
            [_delegate facebookAuthFailed:error];
        }
        
        else {

            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser objectID]];
            NSMutableDictionary *aDictResponse = [NSMutableDictionary dictionaryWithDictionary:FBuser];
            [aDictResponse setObject:userImageURL forKey:@"image"];
            [_delegate facebookAuthSucceedWithUserData:aDictResponse];
        }
    }];
    
    
}

-(void)logOutFromFacebook{
    if([FBSession activeSession]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMVFacebookAccessTokenKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [FBSession.activeSession closeAndClearTokenInformation];
//        [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
//            NSLog(@"%@", error);
//        }];
//        [FBSession setActiveSession:nil];
    }
}

@end
