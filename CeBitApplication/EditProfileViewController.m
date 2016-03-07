//
//  EditProfileViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 19.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AFNetworking.h"
#import <Quickblox/Quickblox.h>
#import "PasswordGenerator.h"
#import <QMServices.h>
#import "UserProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

@synthesize user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameField addRegx: @"^(\w+\S+)$"  withMsg: @"Enter valid name"];
    [self.countryField addRegx: @"^(\w+\S+)$"  withMsg: @"Enter valid country"];
    [self.emailField addRegx: @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withMsg:@"Enter valid email."];
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"Sign up" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController setNavigationBarHidden: NO];
    //[self.profileImageView setImage: [UIImage imageNamed: @"profile.jpg"]];
    /*self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;*/
    int imageSize = 140;
    
    NSLog(@"Profile image: %@", self.user.profileImage);
    
    UIImage *image = [UIImage imageNamed: @"profile.jpg"];
    NSString *editProfile = [[NSUserDefaults standardUserDefaults] objectForKey: @"editProfile"];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = screen.size.width;
    CGFloat height = screen.size.height;
    
    
    UIImage *img = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: self.user.profileImage]]];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - imageSize + (imageSize / 2), 10, imageSize, imageSize)];

    
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.layer.masksToBounds = YES;
    [imgView setImage: img];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.scrollView addSubview: imgView];

    [self.nameField setText: @"Text"];
    
    if (self.user != nil) {
        NSLog([self.user toString]);
        [self setProfileDataOnView: user];
    }
    else if ([[NSUserDefaults standardUserDefaults] objectForKey: @"editProfile"] != nil) {
        NSLog(@"Edit Profile Controller");
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        NSDictionary *user = [cache objectForKey: @"user"];
        if ([cache objectForKey: @"editProfile"] != nil) {
            
            UIImage *image = [UIImage imageNamed: @"profile.jpg"];
            NSString *editProfile = [[NSUserDefaults standardUserDefaults] objectForKey: @"editProfile"];
            
            CGRect screen = [[UIScreen mainScreen] bounds];
            CGFloat width = screen.size.width;
            CGFloat height = screen.size.height;
            
            UIImage *img = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: user[@"profile_image"]]]];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - imageSize + (imageSize / 2), 10, imageSize, imageSize)];
            
            imgView.layer.cornerRadius = imgView.frame.size.width / 2;
            imgView.layer.masksToBounds = YES;
            [imgView setImage: img];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            
            [self.scrollView addSubview: imgView];
            
            [self.nameField setText: user[@"name"]];
            [self.emailField setText: user[@"email"]];
            [self.countryField setText: user[@"country"]];
            [self.placeOfWorkField setText: user[@"place_of_work"]];
            [self.positionField setText: user[@"position"]];
            
            [self.registerBtn setTitle: @"Save" forState: UIControlStateNormal];
            [cache setObject: @"userForEdit" forKey: @"userForEdit"];
            [cache synchronize];
        }
    }
    
}

- (void) setProfileDataOnView: (User *) user {
    if (user != nil) {
        [self.nameField setText: user.name];
        [self.emailField setText: user.email];
        [self.countryField setText: user.country];
        [self.placeOfWorkField setText: user.placeOfWork];
        [self.positionField setText: user.position];
    }
}

- (IBAction)expertInCategories:(id)sender {
}

- (IBAction)lookingForExpertsInCategories:(id)sender {
}

- (IBAction)registerNewUser:(id)sender {
    //if (![self.emailField validate]) return;
    //if (![self.nameField validate]) return;
    //if (![self.countryField validate]) return;
    /*if (![self validateUserForm]) {
        //[self showWarningDialog: @"Error" message: @"All fields are required!"];
        return;
    }*/
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if ([cache objectForKey: @"userForEdit"] != nil && [cache objectForKey: @"editProfile"] != nil) {
        NSMutableDictionary *editUser = [[NSMutableDictionary alloc] init];
        [editUser setObject: self.nameField.text forKey: @"name"];
        [editUser setObject: self.emailField.text forKey: @"email"];
        [editUser setObject: self.countryField.text forKey: @"country"];
        [editUser setObject: self.placeOfWorkField.text forKey: @"place_of_work"];
        [editUser setObject: self.positionField.text forKey: @"position"];
        
        NSMutableDictionary *user = [[cache objectForKey: @"user"] mutableCopy];
        [user setObject: self.nameField.text forKey: @"name"];
        [user setObject: self.emailField.text forKey: @"email"];
        [user setObject: self.countryField.text forKey: @"country"];
        [user setObject: self.placeOfWorkField.text forKey: @"place_of_work"];
        [user setObject: self.positionField.text forKey: @"position"];
        
        [cache synchronize];
        
        NSLog(@"User for edit: %@", editUser);
        
        NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
        NSString *requestURL = [NSString stringWithFormat: @"%@users/%@", apiURL, [cache objectForKey: @"user"][@"id"]];
        
        NSLog(@"Request URL: %@", requestURL);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:user[@"access_token"] forHTTPHeaderField:  @"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [manager PATCH: requestURL parameters:editUser success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"Updated successfully!");
            NSDictionary *responseUser = (NSDictionary *) responseObject;
            NSLog(@"Reponse updated user: %@", responseUser);
            
            
            //Update User in cache
            NSMutableDictionary *newUser = [[cache objectForKey: @"user"] mutableCopy];
            [newUser setObject: responseUser[@"name"] forKey: @"name"];
            [newUser setObject: responseUser[@"email"] forKey: @"email"];
            [newUser setObject: responseUser[@"country"] forKey: @"country"];
            [newUser setObject: responseUser[@"place_of_work"] forKey: @"place_of_work"];
            [newUser setObject: responseUser[@"position"] forKey: @"position"];

            [cache setObject: newUser forKey: @"user"];
            [cache synchronize];
            
            //////////////
            //UserProfileViewController *vc = [[UserProfileViewController alloc] init];
            //[self.navigationController presentViewController: vc animated: YES completion: nil];
            
            [self dismissViewControllerAnimated:YES completion: nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
        }];
        
    }
    
    else {
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, @"users"];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    
    [userData setObject: self.nameField.text forKey: @"name"];
    [userData setObject: self.emailField.text forKey: @"email"];
    [userData setObject: self.countryField.text forKey: @"country"];
    [userData setObject: self.placeOfWorkField.text forKey: @"place_of_work"];
    [userData setObject: self.positionField.text forKey: @"position"];
    [userData setObject: self.user.profileImage forKeyedSubscript: @"profile_image"];
    [userData setObject: self.user.accessToken forKey: @"access_token"];
    [userData setObject: self.user.authorizationType forKey: @"auth_type"];
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:requestURL parameters: userData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
        NSDictionary *responseUser = (NSDictionary *) responseObject;
        
        //Save response user to local application cache
        [self saveRegisteredUserToCache: responseUser];
        
        NSLog(@"User id: %@", responseUser[@"id"]);
        NSLog(@"Access token: %@", responseUser[@"access_token"]);
        NSString *userId = [NSString stringWithFormat: @"%@", responseUser[@"id"]];
        
        //Save user's categories
        [self saveUserCategories: manager userId: userId accessToken: responseUser[@"access_token"]];
        
        //Sign up QuickBlox User
        QBUUser *qbUser = [QBUUser user];
        qbUser.externalUserID = [responseUser[@"id"] integerValue];
        qbUser.login = [NSString stringWithFormat:@"brainr%lu", (unsigned long)qbUser.externalUserID];
        qbUser.email = [NSString stringWithFormat:@"brainr%lu@mail.com", (unsigned long)qbUser.externalUserID];
        qbUser.password = [NSString stringWithFormat:@"brainr%lu", (unsigned long)qbUser.externalUserID];
        qbUser.website = responseUser[@"profile_image"] != nil ? responseUser[@"profile_image"] : @"";
        qbUser.fullName = responseUser[@"name"] != nil ? responseUser[@"name"] : @"";

        NSLog(@"EditProfileViewController:registration%@", qbUser);
        
        [QMServicesManager.instance logInWithUser:qbUser completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                NSLog(@"EditProfileViewController:loginQuickBlox CurrentUser=%@",QMServicesManager.instance.currentUser);
            }else{
                 NSLog(@"EditProfileViewController:loginQuickBlox error: %@", errorMessage);
                [QBRequest signUp:qbUser successBlock:^(QBResponse *response, QBUUser *temp) {
                    
                    NSLog(@"EditProfileViewController:signUp CurrentUser=%@",QMServicesManager.instance.currentUser);
                    //Navigate to matching's view
                    //[self performSegueWithIdentifier: @"showMatches" sender: self];
                    [QMServicesManager.instance logInWithUser:qbUser completion:^(BOOL success, NSString *errorMessage) {
                        if (success) {
                            NSLog(@"EditProfileViewController:loginQuickBlox CurrentUser=%@",QMServicesManager.instance.currentUser);
                        }else{
                            NSLog(@"EditProfileViewController:signUp error: %@", errorMessage);
                        }
                    }];
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"EditProfileViewController:signUp error: %@", response.error);
                }];
            }
        }];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
        
    }
}

-(void) saveUserCategories: (AFHTTPSessionManager *) manager userId: (NSString *) userId accessToken: (NSString *) accessToken {
    //should to set User's categories from cache
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSLog(@"API URL: %@", apiURL);
    //NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"users/%@/categories", [NSString stringWithFormat: @"%@", userId]]];
    NSString *url = [NSString stringWithFormat: @"users/%@/categories", userId];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, url];
    
    NSLog(@"API URL: %@", requestURL);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableArray *userCategories = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"expertInCategories"];
    
    NSMutableArray *idArray = [NSMutableArray array];
    for (int i = 0; i < [userCategories count]; i++)
        [idArray addObject: [userCategories objectAtIndex: i][@"id"]];
    
    [params setObject: idArray forKey: @"categories"];
    
    NSLog(@"%@", params);
    
    [manager.requestSerializer setValue: accessToken forHTTPHeaderField:@"Authorization"];
    [manager POST: requestURL parameters: params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Categories response: %@", responseObject);
        
        [self saveLookingForExpertsInCategories: manager userId: userId accessToken: accessToken];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
    
}

-(void) saveLookingForExpertsInCategories: (AFHTTPSessionManager *) manager userId: (NSString *) userId accessToken: (NSString *) accessToken {
    //should to set User's categories from cache
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSLog(@"API URL: %@", apiURL);
    //NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"users/%@/categories", [NSString stringWithFormat: @"%@", userId]]];
    NSString *url = [NSString stringWithFormat: @"users/categories/lookingFor/%@", userId];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, url];
    
    NSLog(@"API URL: %@", requestURL);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableArray *userCategories = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"lookingForExperts"];
    
    NSMutableArray *idArray = [NSMutableArray array];
    for (int i = 0; i < [userCategories count]; i++)
        [idArray addObject: [userCategories objectAtIndex: i][@"id"]];
    
    [params setObject: idArray forKey: @"categories"];
    
    NSLog(@"%@", params);
    
    [manager.requestSerializer setValue: accessToken forHTTPHeaderField:@"Authorization"];
    [manager POST: requestURL parameters: params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Looking for experts categories %@", responseObject);
        
        //Navigate to matching's view
        [self performSegueWithIdentifier: @"showMatches" sender: self];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

-(BOOL) validateUserForm {
    if ([self.nameField.text isEqualToString: @""] || [self.emailField.text isEqualToString: @""] ||
        [self.countryField.text isEqualToString: @""] || [self.placeOfWorkField.text isEqualToString: @""] ||
        [self.positionField.text isEqualToString: @""]) return NO;
    return YES;
}

-(void) showWarningDialog: (NSString *) title message: (NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void) saveRegisteredUserToCache: (NSDictionary *) responseData {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    [cache setObject: responseData forKey: @"user"];
    
    /*User *user = [User init];
    [user setUserId: [NSString stringWithFormat: @"%@", responseData[@"id"]].integerValue];
    [user setName: responseData[@"name"]];
    [user setEmail: responseData[@"email"]];
    [user setCountry: responseData[@"country"]];
    [user setPlaceOfWork: responseData[@"place_of_work"]];
    [user setPosition: responseData[@"position"]];
    [user setAccessToken: responseData[@"access_token"]];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden: NO];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *expertInCategories = (NSMutableArray *)[cache objectForKey: @"expertInCategories"];
    NSMutableArray *lookingForExperts = (NSMutableArray *)[cache objectForKey: @"lookingForExperts"];
    
    
    NSString *newBtnTitle = [NSString stringWithFormat: @"Selected categories: %@", [NSString stringWithFormat: @"%lu", (unsigned long)[expertInCategories count]]];
    [self.expertInCategoriesButton setTitle: newBtnTitle forState: UIControlStateNormal];
    
    NSString *newBtnForExpertsTitle = [NSString stringWithFormat: @"Selected categories: %@", [NSString stringWithFormat: @"%lu", (unsigned long)[lookingForExperts count]]];
    [self.loogingForExpertsInCategoriesButton setTitle: newBtnForExpertsTitle forState: UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"browser"];
    
    //NSLog(@"%@", expertInCategories);
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"userForEdit"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"editProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showMatches"]) {
        
    }
}

@end