//
//  ViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 18.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"

@interface LoginController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *loginScreen;

@property (strong) User *user;
@property NSMutableArray *categories;
@property NSMutableArray *userCategories;
@property NSMutableArray *searchForExpertsCategories;

@property NSString *authType;
@property NSString *accessToken;

- (IBAction)facebookAuth:(UIButton *)sender;
- (IBAction)twitterAuth:(UIButton *)sender;
- (IBAction)linkedinAuth:(UIButton *)sender;

-(void) getFacebookUser;
- (void) createLinkedInUser;

@end