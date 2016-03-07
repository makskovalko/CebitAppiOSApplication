//
//  LinkedInOAuthViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 28.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "LinkedInOAuthViewController.h"

@interface LinkedInOAuthViewController ()

@end

@implementation LinkedInOAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.linkedInKey = @"77252se65atora";
    self.linkedInSecret = @"K7ltk2uDccQLPtVy";
    self.authorizationEndpoint = @"https://www.linkedin.com/uas/oauth2/authorization";
    self.accessTokenEndPoint = @"https://www.linkedin.com/uas/oauth2/accessToken";
    
    self.webView.delegate = self;
    
    [self startAuthorization];
}

- (void) startAuthorization {
    NSString *responseType = @"code";
    NSString *apiURL = @"http://localhost:3240/api/";//(NSString *) [[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *redirectURL = [[NSString stringWithFormat: @"%@linkedin/oauth", apiURL] stringByAddingPercentEncodingWithAllowedCharacters:
                            [NSCharacterSet alphanumericCharacterSet]];
    NSString *state = [NSString stringWithFormat: @"linkedin%f", [[[NSDate alloc] init] timeIntervalSince1970]];
    NSString *scope = @"r_basicprofile,r_emailaddress";
    
    NSString *authorizationURL = [NSString stringWithFormat: @"%@?response_type=%@&client_id=%@&redirect_uri=%@&state=%@&scope=%@",
                                  self.authorizationEndpoint, responseType, self.linkedInKey, redirectURL, state, scope];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: authorizationURL]];
    [self.webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    
    NSLog(@"Current url: %@", url.absoluteString);
    
    if ([url.absoluteString containsString: @"linkedin/oauth"] && [url.absoluteString containsString: @"code"]) {
        NSArray<NSString *> *urlParts = [url.absoluteString componentsSeparatedByString: @"?"];
        NSString *code = [[urlParts[1] componentsSeparatedByString: @"="] objectAtIndex: 1];
        [self requestForAccessToken: code];
    } else if ([url.absoluteString containsString: @"error=access_denied"])
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated: YES completion: nil];
        });
    
    return YES;
}

- (void) requestForAccessToken:(NSString *)authorizationCode {
    
    NSString *grantType = @"authorization_code";
    NSString *apiURL = @"http://localhost:3240/api/";//(NSString *) [[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *redirectURL = [[NSString stringWithFormat: @"%@linkedin/oauth", apiURL] stringByAddingPercentEncodingWithAllowedCharacters:
                            [NSCharacterSet alphanumericCharacterSet]];
    NSString *postParams = [NSString stringWithFormat: @"grant_type=%@&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@",
                            grantType, authorizationCode, redirectURL, self.linkedInKey, self.linkedInSecret];
    NSData *postData = [postParams dataUsingEncoding: NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.accessTokenEndPoint]];

    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request addValue: @"application/x-www-form-urlencoded;" forHTTPHeaderField: @"Content-Type"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger *statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode == 200) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
            NSString *accessToken = jsonData[@"access_token"];
            
            NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *socialData = [[NSMutableDictionary alloc] init];
            [socialData setObject: @"linkedin" forKey: @"auth_type"];
            [socialData setObject: accessToken forKey: @"access_token"];
            [socialData setObject: @"browser" forKey: @"browser"];
            [cache setObject: socialData forKey: @"social_data"];
            [cache synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated: YES completion: nil];
            });
            
        }
    }];
    
    [task resume];
    
}

- (IBAction)closeBtn:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end