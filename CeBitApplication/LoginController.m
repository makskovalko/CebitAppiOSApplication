//
//  ViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 18.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "LoginController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <linkedin-sdk/LISDKSessionManager.h>
#import <linkedin-sdk/LISDKAPIHelper.h>
#import "User.h"
#import "HttpRequestsWorker.h"
#import "EditProfileViewController.h"
#import "AFNetworking.h"
#import "CategoryRestController.h"
#import "Categories.h"
#import <Quickblox/Quickblox.h>
#import <TwitterKit/TwitterKit.h>
#import <QMServices.h>

@interface LoginController ()
    
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIImage *image = [UIImage imageNamed:@"fon"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden: YES];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *socialData = [cache objectForKey: @"social_data"];
    NSLog(@"Access token: %@\nAuth type: %@", socialData[@"access_token"], socialData[@"auth_type"]);
    
    if (socialData != nil && socialData[@"auth_type"] != nil && [socialData[@"auth_type"] isEqualToString: @"linkedin"]
        && [socialData[@"browser"] isEqualToString: @"browser"])
            [self createLinkedInUser];
    
}

- (void) checkExistingUser: (NSString *) accessToken authType: (NSString *) authType {
    
    NSLog(@"Check user: %@%@", accessToken, authType);
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, @"getExistingUser"];
    
    NSMutableDictionary *socialData = [[NSMutableDictionary alloc] init];
    [socialData setObject: accessToken forKey: @"access_token"];
    [socialData setObject: authType forKey: @"auth_type"];
    [[NSUserDefaults standardUserDefaults] setObject: socialData forKey: @"social_data"];
    
    NSLog(@"Social data: %@", socialData);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:requestURL parameters: socialData progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseUser = (NSDictionary *) responseObject;
        
        NSLog(@"Response user: %@", responseUser);
        
        //Save response user to local application cache
        if (responseUser != nil) {
            NSLog(@"%@", responseUser);
            
            NSLog(@"User id: %@", responseUser[@"id"]);
            NSLog(@"Access token: %@", responseUser[@"access_token"]);
            NSString *userId = [NSString stringWithFormat: @"%@", responseUser[@"id"]];

            NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
            [user setObject: responseUser[@"id"] != nil ? responseUser[@"id"] : @"" forKey: @"id"];
            [user setObject: responseUser[@"name"] != nil ? responseUser[@"name"] : @"" forKey: @"name"];
            [user setObject: responseUser[@"email"] != nil ? responseUser[@"email"] : @"" forKey: @"email"];
            [user setObject: responseUser[@"position"] != nil ? responseUser[@"position"] : @"" forKey: @"position"];
            [user setObject: responseUser[@"place_of_work"] != nil ? responseUser[@"place_of_work"] : @"" forKey: @"place_of_work"];
            [user setObject: responseUser[@"access_token"] != nil ? responseUser[@"access_token"] : @"" forKey: @"access_token"];
            [user setObject: responseUser[@"country"] ? responseUser[@"country"] : @"" forKey: @"country"];
            //[user setObject: responseUser[@"city"] != nil ? responseUser[@"city"] : @"" forKey: @"city"];
            [user setObject: responseUser[@"profile_image"] != nil ? responseUser[@"profile_image"] : @"" forKey: @"profile_image"];
            [user setObject: @"true" forKey: @"is_exists"];
            
            NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
            [cache setObject: user forKey: @"user"];
            [cache setObject: accessToken forKey: @"access_token"];
            [cache setObject: authType forKey: @"auth_type"];
            [cache setObject: responseUser[@"expertInCategories"] forKey: @"expertInCategories"];
            [cache setObject: responseUser[@"lookingForExperts"] forKey: @"lookingForExperts"];
            [cache synchronize];
            
            QBUUser *qbUser = [QBUUser user];
            qbUser.externalUserID = [responseUser[@"id"] integerValue];
            qbUser.login = [NSString stringWithFormat:@"brainr%lu", (unsigned long)qbUser.externalUserID];
            qbUser.email = [NSString stringWithFormat:@"brainr%lu@mail.com", (unsigned long)qbUser.externalUserID];
            qbUser.website = responseUser[@"profile_image"] != nil ? responseUser[@"profile_image"] : @"";
            qbUser.fullName = responseUser[@"name"] != nil ? responseUser[@"name"] : @"";
            qbUser.password = [NSString stringWithFormat:@"brainr%lu", (unsigned long)qbUser.externalUserID];
            NSLog(@"User's data: %@", user);
            [QMServicesManager.instance logInWithUser:qbUser completion:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    NSLog(@"LoginController:checkUser:loginQuickBlox CurrentUser=%@",QMServicesManager.instance.currentUser);
                    [self performSegueWithIdentifier: @"showUsersProfile" sender: self];
                }else{
                    NSLog(@"LoginController:checkUser error: %@", errorMessage);
                }
            }];
            
            
        } else [self getAllCategories: accessToken];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        [self getAllCategories: accessToken];
    }];
}

- (IBAction)facebookAuth:(UIButton *)sender {
    NSLog(@"Facebook authorization");
    
    if (![FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        
        [loginManager logInWithReadPermissions: @[@"public_profile", @"email", @"user_about_me", @"user_location", @"user_photos", @"user_birthday"]
                            fromViewController: self
                            handler:^(FBSDKLoginManagerLoginResult *result,
                            NSError *error) {
                                NSLog(@"%@", [FBSDKAccessToken currentAccessToken].tokenString);
                                if ([FBSDKAccessToken currentAccessToken]) [self getFacebookUser];
                            }];
    }
    
    else if ([FBSDKAccessToken currentAccessToken]) [self getFacebookUser];
    
}

- (IBAction)twitterAuth:(UIButton *)sender {
    [self createTwitterUser];
}

- (IBAction)linkedinAuth:(UIButton *)sender {
    
}

- (void) getFacebookUser {
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    FBSDKGraphRequest *requestMe = [[[FBSDKGraphRequest alloc] initWithGraphPath: @"me" parameters: nil] startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) NSLog(@"Fetched user: %@", result);
        NSDictionary *userData = (NSDictionary *) result;
        
        NSString *userId = userData[@"id"];
        NSString *userName = userData[@"name"];
        
        //Call Graph API method
        NSString *url = [NSString stringWithFormat: @"https://graph.facebook.com/%@?fields=name,email,gender,age_range,picture,location&access_token=%@",
                         userId, [FBSDKAccessToken currentAccessToken].tokenString];
        
        NSDictionary *jsonData = [HttpRequestsWorker getDataFrom: url];
        NSDictionary *profileImage = [HttpRequestsWorker getDataFrom:
                                      [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?redirect=false&width=150&height=150",
                                      jsonData[@"id"]]][@"data"][@"url"];
        
        NSLog(@"%@", jsonData);
        NSLog(@"Profile image: %@", profileImage);
        
        //Create User and send data to Edit Profile View
        
        User *user = [self createFacebookUser: jsonData];
        [user setAuthorizationType: [NSString stringWithFormat: @"facebook"]];
        [user setAccessToken: jsonData[@"id"]];
        //[user setAccessToken: [FBSDKAccessToken currentAccessToken].tokenString];
        [user setProfileImage: profileImage];
        self.user = user;
        self.authType = @"facebook";
        self.accessToken = jsonData[@"id"]; //[FBSDKAccessToken currentAccessToken].tokenString;
        
        [self checkExistingUser: self.accessToken authType: self.authType];
        //[self getAllCategories: [FBSDKAccessToken currentAccessToken].tokenString];
        
    }];

}

- (void) getAllCategories: (NSString *) accessToken {
    if (self.user != nil) {
        NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, @"categories"];
        
        [manager GET: requestURL parameters: nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray *categories = (NSMutableArray *) responseObject;
            self.categories = categories;
            //NSLog(@"Mut Array: %@", self.categories);

            NSMutableArray *resArray = [NSMutableArray array];
            for (int i = 0; i < [self.categories count]; i++) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                [temp setObject: [self.categories objectAtIndex: i][@"id"] forKey: @"id"];
                [temp setObject: [self.categories objectAtIndex: i][@"name"] forKey: @"name"];
                [resArray addObject: temp];
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject: resArray forKey: @"categories"];
            
            //Get user from cache
            NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];
            
            if (user != nil) {
                NSString *urlForUserCategories = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"users/%@/categories", user[@"id"]]];

                [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField:@"Authorization"];
                
                [manager GET: urlForUserCategories parameters: nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    self.userCategories = (NSArray *) responseObject;
                    if (self.userCategories.count == 0) NSLog(@"No categories!");
                    
                    //Send data with user profile and his categories and all categories to Edit Profile View
                    if (user[@"is_exists"] == nil || [user[@"is_exists"] isEqualToString: @"false"])
                         [self performSegueWithIdentifier: @"userDataForProfile" sender: self];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"%@", error);
                    [self showError];
                }];
            } else {
                //self.userCategories
                //Send data with user profile and his categories and all categories to Edit Profile View
                [self performSegueWithIdentifier: @"userDataForProfile" sender: self];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            [self showError];
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Network error. Please check your network connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(User *)createFacebookUser: (NSDictionary *) data {
    User *user = [[User alloc] init];
    
    [user setName: data[@"name"]];
    [user setEmail: data[@"email"]];
    [user setPhoneNumber: data[@"phone_number"]];
    [user setAuthorizationType: @"facebook"];
    [user setAccessToken: data[@"id"]];
    
    NSString *location = data[@"location"][@"name"];
    
    //NSLog(@"%@", location);
    
    NSString *city = [location componentsSeparatedByString: @", "][1];
    NSString *country = [location componentsSeparatedByString: @", "][0];
    
    [user setCountry: city];
    [user setCity: country];
    
    return user;
}

-(void) createTwitterUser {
    User *twitterUser = [[User alloc] init];
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@\nAuth token: %@", [session userName], [session authToken]);
            
            TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc] initWithCompletion:^(NSString* email, NSError* error) {
                if (error) [twitterUser setEmail: @""];
                else [twitterUser setEmail: email];
                
                TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID: [session userID]];
                
                [client loadUserWithID: [session userID] completion:^(TWTRUser *user, NSError *error) {
                    if (user) {
                        NSError *error;
                        
                        [twitterUser setAccessToken: [session userID]];
                        [twitterUser setName: [user name]];
                        [twitterUser setProfileImage: [user profileImageLargeURL]];
                        [twitterUser setAuthorizationType: @"twitter"];
                        
                        self.user = twitterUser;
                        self.authType = @"twitter";
                        self.accessToken = self.user.accessToken;
                        
                        NSLog(@"AuthType: %@%@", self.authType, self.accessToken);
                        
                        [self checkExistingUser: self.accessToken authType: self.authType];
                        
                        //[self getAllCategories: [self.user accessToken]];
                        
                    }
                    else if (error) NSLog(@"%@", error);
                }];
                
            }];
            
            [self presentViewController:shareEmailViewController animated:YES completion:nil];
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
}

- (void) createLinkedInUser {
    User *linkedInUser = [[User alloc] init];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *socialData = [cache objectForKey: @"social_data"];
    
    NSString *profileLinkedInURL = @"https://api.linkedin.com/v1/people/~:(picture-urls::(original),formatted-name,id,location,industry,summary,specialties,positions,headline,email-address)?format=json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: profileLinkedInURL]];
    
    request.HTTPMethod = @"GET";
    [request addValue: [NSString stringWithFormat: @"Bearer %@", socialData[@"access_token"]] forHTTPHeaderField: @"Authorization"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger *statusCode = [(NSHTTPURLResponse *) response statusCode];
        if (statusCode == 200) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
            NSLog(@"%@", jsonData);
            
            [linkedInUser setName: jsonData[@"formattedName"]];
            [linkedInUser setEmail: jsonData[@"emailAddress"]];
            [linkedInUser setCountry: jsonData[@"location"][@"name"]];
            [linkedInUser setPosition: jsonData[@"headline"] != nil ? jsonData[@"headline"] : jsonData[@"positions"][@"values"][0][@"title"]];
            [linkedInUser setPlaceOfWork: jsonData[@"positions"][@"values"][0][@"company"][@"name"]];
            [linkedInUser setProfileImage: jsonData[@"pictureUrls"][@"values"][0]];
            [linkedInUser setAccessToken: jsonData[@"id"]];
            [linkedInUser setAuthorizationType: @"linkedin"];
            
            self.user = linkedInUser;
            self.authType = @"linkedin";
            self.accessToken = jsonData[@"id"];
            
            //[self getAllCategories: [self.user accessToken]];
            
        }
        
        [self checkExistingUser: self.accessToken authType: self.authType];
        
    }];
    
    [task resume];
}

- (void) showError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Network error. Please check your network connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"userDataForProfile"]) {
        EditProfileViewController *editController = [segue destinationViewController];
        editController.user = self.user;
        editController.categories = self.categories;
        editController.userCategories = self.userCategories;
        
        //Save data for Social Authentification (auth_type, access_token)
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *socialData = [[NSMutableDictionary alloc] init];
        [socialData setObject: self.authType forKey: @"auth_type"];
        [socialData setObject: self.accessToken forKey: @"access_token"];
        [cache setObject: socialData forKey: @"social_data"];
    }
}

@end