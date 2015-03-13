//
//  MVTwitterAuthentication.h
//  TwitterDemo
//
//  Created by Mrugraj on 18/11/14.
//   
//

#import <Foundation/Foundation.h>
#import "FHSTwitterEngine.h"
#define kMVTwitterAccessTokenKey @"MVTwitterAccessToken"
@protocol MVTwitterAuthenticationDelegate <NSObject>

-(void)twitterAuthenticationSucceedWithUserData:(NSDictionary*)userInfo;
-(BOOL)twitterAuthenticationDoneShouldGoForData;
-(void)twitterAuthenticationFailed:(NSError*)error;
-(void)twitterAuthenticationFailedAtAccounts;

-(BOOL)twitterauthenticationShouldHandleFallback;
-(NSString*)twitterAuthenticationNeedsConsumerKey;
-(NSString*)twitterAuthenticationNeedsSecret;
-(UIViewController*)twitterAuthenticationWillLoadWebViewForController;

-(void)twitterAuthenticationStarted;
-(void)twitterAuthenticationEnded;

@end

@interface MVTwitterAuthentication : NSObject<FHSTwitterEngineAccessTokenDelegate>

@property(nonatomic,strong)NSString *strScreenName;
@property(nonatomic,strong)NSString *strName;
@property(nonatomic,strong)NSString *strTwitterId;
@property(nonatomic,strong)NSString *strTwitterEmail;
@property(nonatomic,strong)NSString *strAccessToken;

@property(nonatomic,strong)id<MVTwitterAuthenticationDelegate> twitterDelegate;
@property(nonatomic,readonly,strong)NSDictionary *userInfo;


+(MVTwitterAuthentication*)sharedInstance;
-(void)authenticateViaTwitterWithDelegate:(id<MVTwitterAuthenticationDelegate>)delegate;
-(NSDictionary *)userInfo:(BOOL)basicDetail;
-(void)logoutFromTwitter;
@end
