//
//  MVSocialAuthViewController.m
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import "MVSocialAuthViewController.h"


@interface MVSocialAuthViewController ()@end

@implementation MVSocialAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_facebookButton)
    [_facebookButton addTarget:self action:@selector(authViaFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    if(_twitterButton)
    [_twitterButton addTarget:self action:@selector(authViaTwitter) forControlEvents:UIControlEventTouchUpInside];
    
    if(_googleButton)
    [_googleButton addTarget:self action:@selector(authViaGoogle) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"=================MEMORY ERROR===========:%@",NSStringFromClass([self class]));
    // Dispose of any resources that can be recreated.
}



-(void)setFacebookButton:(UIButton *)facebookButton{
    _facebookButton=facebookButton;
    if(_facebookButton)
        [_facebookButton addTarget:self action:@selector(authViaFacebook) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)setGoogleButton:(UIButton *)googleButton{
    _googleButton = googleButton;
    if(_googleButton)
        [_googleButton addTarget:self action:@selector(authViaGoogle) forControlEvents:UIControlEventTouchUpInside];
}
-(void)setTwitterButton:(UIButton *)twitterButton{
    _twitterButton =twitterButton;
    if(_twitterButton)
        [_twitterButton addTarget:self action:@selector(authViaTwitter) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Social Calls
-(void)authViaFacebook{
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        [[AppDelegate sharedInstance] showAlertForRechabilityIssue];
        return;
    }
    [[MVSocialAuthObject sharedInstance]authenticateViaFacebookDelegate:self];
}

-(void)authViaTwitter{
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        [[AppDelegate sharedInstance] showAlertForRechabilityIssue];
        return;
    }
    [[MVSocialAuthObject sharedInstance]authenticateViaTwitterDelegate:self];

}

-(void)authViaGoogle{
    if(![AFNetworkReachabilityManager sharedManager].reachable){
        [[AppDelegate sharedInstance] showAlertForRechabilityIssue];
        return;
    }
    [[MVSocialAuthObject sharedInstance]authenticateViaGoogleDelegate:self];
}


#pragma mark ----------------------
#pragma mark Authentication delegaet


-(void)authenticataionDidFailedByType:(MVAuthType)authType withError:(NSError *)error{
    NSLog(@"---------------------------\nAUTH FAILED AT TYPW: %u ERROR:%@",authType,error);
}
-(void)authenticataionDidFinishedWithType:(MVAuthType)authType andAccessData:(NSDictionary *)userInfo{
    NSLog(@"---------------------------\nAUTH FINISHED WITH TYPE : %u INFO:%@",authType,userInfo);
}
-(void)authenticateionDidStartedWithType:(MVAuthType)authType{
    NSLog(@"---------------------------\nAUTHENTICATION STARTED WITH  TYPE %u........",authType);
}








@end
