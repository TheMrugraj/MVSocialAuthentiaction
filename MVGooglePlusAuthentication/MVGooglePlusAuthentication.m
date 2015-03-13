//
//  MVGooglePlusAuthentication.m
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import "MVGooglePlusAuthentication.h"

@implementation MVGooglePlusAuthentication


static MVGooglePlusAuthentication *sharedInstance = nil;


+(MVGooglePlusAuthentication*)sharedInstance
{
    @synchronized([MVGooglePlusAuthentication class])
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        
        return sharedInstance;
    }
    
    return nil;
}

-(void)logoutFromGoogle{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kMVGoogleAccessTokenKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[GPPSignIn sharedInstance]signOut];
}
-(void)authenticateViaGoogleWithClientKey:(NSString *)clientId delegate:(id<MVGooglePlusDelegate>)delegate{
 
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = clientId;
    signIn.scopes = [NSArray arrayWithObject:kGTLAuthScopePlusLogin];
    signIn.delegate = self;
    
    _googleDelegate=delegate;
    [_googleDelegate googleAuthStarted];
    [signIn authenticate];
    
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if(!error){
        
        _aceessTokenInfo = [NSDictionary dictionaryWithObjectsAndKeys:auth.accessToken,@"accessToken",auth.expirationDate,@"expirationDate",auth.refreshToken,@"refreshToken", nil]
        ;
        [[NSUserDefaults standardUserDefaults]setObject:_aceessTokenInfo forKey:kMVGoogleAccessTokenKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self fetchUserBasicDetail];
        
        [_googleDelegate googleAuthEnded];
    }else{
        [_googleDelegate googleAuthFailed:error];
    }

}


-(void)fetchUserBasicDetail{
    // 1. Create a |GTLServicePlus| instance to send a request to Google+.
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
    plusService.retryEnabled = YES;
    
    // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    // *4. Use the "v1" version of the Google+ API.*
    plusService.apiVersion = @"v1";
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    [_googleDelegate googleAuthFailed:error];
                    //Handle Error
                    
                } else
                {
                    
                    
                    if(_userInfo){
                        [_userInfo  removeAllObjects];
                        _userInfo = nil;
                    }
                    
                    _userInfo = [NSMutableDictionary dictionary];
                    [_userInfo setObject:[GPPSignIn sharedInstance].authentication.userEmail forKey:@"email"];

                    [_userInfo setObject:person.identifier forKey:@"id"];
                    [_userInfo setObject:person.name?person.name.givenName:@"" forKey:@"userName"];

                    [_userInfo setObject:person.gender ?person.gender :@""forKey:@"gender"];
                    [_userInfo setObject:person.image.url?person.image.url:@"" forKey:@"image"];
                    [_userInfo setObject:person.cover?person.cover.coverPhoto.url:@"" forKey:@"cover"];
                    [_userInfo setObject:person.nickname?person.nickname:@"" forKey:@"nickName"];                    
                    [_googleDelegate googleAuthSucceedWithUserData:_userInfo];
                }
            }];
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    if([(UIViewController*)_googleDelegate navigationController]){
        [[(UIViewController*)_googleDelegate navigationController] pushViewController:viewController animated:YES];
    }
}

@end
