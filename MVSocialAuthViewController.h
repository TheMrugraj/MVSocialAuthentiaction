//
//  MVSocialAuthViewController.h
//  TwitterDemo
//
//  Created by Indianic on 18/11/14.
//  Copyright (c) 2014 Indianic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSocialAuthObject.h"


@interface MVSocialAuthViewController : UIViewController<MVSocialDelegates>
@property(nonatomic,weak)IBOutlet UIButton *facebookButton;
@property(nonatomic,weak)IBOutlet UIButton *twitterButton;
@property(nonatomic,weak)IBOutlet UIButton *googleButton;
@property(nonatomic,strong)id delegate;

@end
