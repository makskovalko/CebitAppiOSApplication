//
//  LinkedInOAuthViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 28.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkedInOAuthViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property NSString *linkedInKey, *linkedInSecret, *authorizationEndpoint, *accessTokenEndPoint;
- (IBAction)closeBtn:(UIBarButtonItem *)sender;

-(void) startAuthorization;
-(void) requestForAccessToken: (NSString *) authorizationCode;

@end