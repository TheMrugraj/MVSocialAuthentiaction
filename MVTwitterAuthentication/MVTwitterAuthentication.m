//
//  MVTwitterAuthentication.m
//  TwitterDemo
//
//  Created by Mrugraj on 18/11/14.
//   
//

#import "MVTwitterAuthentication.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

static MVTwitterAuthentication *sharedInstance = nil;
@implementation MVTwitterAuthentication

+(MVTwitterAuthentication*)sharedInstance
{
    @synchronized([MVTwitterAuthentication class])
    {
        if (!sharedInstance)
            sharedInstance = [[self alloc] init];
        
        return sharedInstance;
    }
    
    return nil;
}



-(void)authenticateViaTwitterWithDelegate:(id<MVTwitterAuthenticationDelegate>)delegate{
    _twitterDelegate = delegate;
    [self getTwitterDataUsingAccountFW];
}

-(void)logoutFromTwitter{
    [[FHSTwitterEngine sharedEngine]clearAccessToken];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kMVTwitterAccessTokenKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)getTwitterDataUsingAccountFW
{
    @try {
        double delayInSeconds2 = 0.1;
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
            if([self callSelector:@selector(twitterAuthenticationStarted) withTarget:_twitterDelegate]){
                [_twitterDelegate twitterAuthenticationStarted];
            }
        });
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
         {
             _strScreenName = @"";
             _strName = @"";
             _strTwitterId = @"";
             _strTwitterEmail = @"";
             
             if (granted)
             {
                 NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                 
                 // Check if the users has setup at least one Twitter account
                 if ([accounts count] > 0)
                 {
                     
                     ACAccount *twitterAccount = [accounts objectAtIndex:0];
                     twitterAccount.accountType = accountType;
                     
                     //User Detail

                     _strScreenName=@"";

                     if(![self isEmptyText:twitterAccount.username])
                     {
                         _strScreenName = twitterAccount.username;
                     }

                     _strTwitterId=@"";
                     if(![self isEmptyText:[[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"]])
                     {
                         _strTwitterId = [[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"];
                     }
                     
                     double delayInSeconds2 = 0.1;
                     dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
                     dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                         NSLog(@"LOGGED IN SUCCEESS FETCHING DATA......");
                         
                         if([self callSelector:@selector(twitterAuthenticationDoneShouldGoForData) withTarget:_twitterDelegate]){
                             if([_twitterDelegate twitterAuthenticationDoneShouldGoForData]){
                                 [self getTwitterData:twitterAccount strScreenName:_strScreenName];
                             }else{
                                 [_twitterDelegate twitterAuthenticationSucceedWithUserData:[self userInfo:YES]];
                                 [_twitterDelegate twitterAuthenticationEnded];
                             }
                         }

                     });
                 }
                 else
                 {
                     double delayInSeconds2 = 0.1;
                     dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
                     dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                         
                         NSLog(@"CHECK ACCOUNTS IN SETTINGS...........");

                         [self processFallBackWithError:[NSError errorWithDomain:@"No ACcounts Found in Settings" code:102 userInfo:nil]];
                         
                     });
                 }
             }
             else
             {
                 double delayInSeconds3 = 0.1;
                 dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
                 dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                     NSLog(@"CHECK ACCOUNTS IN SETTINGS...........");
                     [self processFallBackWithError:error];
                 });
             }
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"getTwitterDataUsingAccountFW :%@",exception);
    }
    @finally {
    }
}




-(void)getTwitterData:(ACAccount *)twitterAccount strScreenName:(NSString *)aStrScreenName
{
    @try {
        // Creating a request to get the info about a user on Twitter
        SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:aStrScreenName forKey:@"screen_name"]];
        [twitterInfoRequest setAccount:twitterAccount];
        
        // Making the request
        [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 // Check if we reached the reate limit
                 if ([urlResponse statusCode] == 429) {
                     return;
                 }
                 
                 // Check if there was an error
                 if (error) {
                     NSLog(@"Error: %@", error.localizedDescription);
                     return;
                 }
                 
                 // Check if there is some response data
                 if (responseData)
                 {
                     NSError *error = nil;
                     NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                     
                     // Filter the preferred data
                     NSLog(@"DATA: %@",TWData);
                    
                     [self setUserInfo:(NSDictionary*)TWData];
                     double delayInSeconds2 = 0.1;
                     dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
                     dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                         NSLog(@"End");
                         if([self callSelector:@selector(twitterAuthenticationSucceedWithUserData:) withTarget:_twitterDelegate]){
                             [_twitterDelegate twitterAuthenticationSucceedWithUserData:_userInfo];
                             [_twitterDelegate twitterAuthenticationEnded];
                         }
                     });
                 }
             });
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"getTwitterData :%@",exception);
    }
    @finally {
    }
}

-(void)processFallBackWithError:(NSError*)error{
    if([self callSelector:@selector(twitterAuthenticationFailedAtAccounts) withTarget:_twitterDelegate]){
        NSLog(@"Error : %@",error);
        [_twitterDelegate twitterAuthenticationFailedAtAccounts];
    }
    
    if([self callSelector:@selector(twitterauthenticationShouldHandleFallback) withTarget:_twitterDelegate]){
        BOOL shouldHandleFallBack = [_twitterDelegate twitterauthenticationShouldHandleFallback];
        if(shouldHandleFallBack){
            NSLog(@"Going For Handlling Fallback");
            
            [self loadTwitterEngineToHangleFallback];
            
            return;
        }else{
            [_twitterDelegate twitterAuthenticationFailed:error];
        }
    }else{
        [_twitterDelegate twitterAuthenticationFailed:error];
    }
    [_twitterDelegate twitterAuthenticationEnded];
}



#pragma mark Twitter Oauth Implementation

-(void)loadTwitterEngineToHangleFallback{
    NSString *aStrConsumerKey   = [_twitterDelegate twitterAuthenticationNeedsConsumerKey];
    NSString *aStrSecret        = [_twitterDelegate twitterAuthenticationNeedsSecret];
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:aStrConsumerKey andSecret:aStrSecret];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"MVTwitterAccessToken"]){
        [[FHSTwitterEngine sharedEngine]loadAccessToken];
        [self authenticationSuccess];
    }else{
        [self loginOAuth];
    }
}

-(void)authenticationSuccess{
    [_twitterDelegate twitterAuthenticationEnded];
    //TODO: Fetch Info of user and Return it
    id user = [[FHSTwitterEngine sharedEngine]showUser];
    
    _userInfo =user;
    if([self callSelector:@selector(twitterAuthenticationSucceedWithUserData:) withTarget:_twitterDelegate]){
        [_twitterDelegate twitterAuthenticationSucceedWithUserData:_userInfo];
        [_twitterDelegate twitterAuthenticationEnded];
    }
}
- (void)loginOAuth {
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"FAILED");
        if(!success){
            [_twitterDelegate twitterAuthenticationFailed:[NSError errorWithDomain:@"Twitter Authentication Failed" code:102 userInfo:nil]];
        }else{
            [self authenticationSuccess];
        }
    }];
    UIViewController *superController = [_twitterDelegate twitterAuthenticationWillLoadWebViewForController];
    if(superController){
        [superController presentViewController:loginController animated:YES completion:nil];
    }
}


-(NSString *)loadAccessToken{
    _strAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kMVTwitterAccessTokenKey];
    if(_strAccessToken)
        return _strAccessToken;
    else
        return nil;
}
-(void)storeAccessToken:(NSString *)accessToken{
    _strAccessToken = accessToken;
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:kMVTwitterAccessTokenKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}



#pragma mark MISC METHODS

-(BOOL)isEmptyText:(NSString*)string{
    if(!string || [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0){
        return YES;
    }else{
        return NO;
    }
}


-(void)setUserInfo:(NSDictionary *)userInfo{
    _userInfo=[NSDictionary dictionaryWithDictionary:userInfo];
    if([self isEmptyText:_strName])
    {
        _strName = [(NSDictionary *)_userInfo objectForKey:@"name"];
    }
    
    if([self isEmptyText:_strScreenName])
    {
        _strScreenName = [(NSDictionary *)_userInfo objectForKey:@"screen_name"];
    }
    
    if([self isEmptyText:_strTwitterId])
    {
        _strTwitterId = [NSString stringWithFormat:@"%@",[(NSDictionary *)_userInfo objectForKey:@"id"]];
    }
    
    if([self isEmptyText:_strTwitterEmail])
    {
        _strTwitterEmail = [(NSDictionary *)_userInfo objectForKey:@"email"];
    }
}
-(NSDictionary *)userInfo:(BOOL)basicDetail{
    if(basicDetail){
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:_strName,@"name",_strScreenName,@"screenName",_strTwitterId,@"id",_strTwitterEmail,@"email", nil];
        return aDict;
    }else{
        return _userInfo;
    }
}


-(BOOL)callSelector:(SEL)selectorName withTarget:(id)target{
    if(target && [target respondsToSelector:selectorName]){
        return YES;
    }else{
        NSLog(@"Selector Not Found");
        return  NO;
    }
}

@end
