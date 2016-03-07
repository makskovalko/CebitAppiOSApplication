//
//  EditProfileViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 19.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TextFieldValidator.h"

@interface EditProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property User *user;
@property NSMutableArray *categories;
@property NSMutableArray *userCategories;
@property NSMutableArray *searchForExpertsCategories;

@property (weak, nonatomic) IBOutlet TextFieldValidator *nameField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *emailField;
@property (weak, nonatomic) IBOutlet TextFieldValidator *countryField;
@property (weak, nonatomic) IBOutlet UITextField *placeOfWorkField;
@property (weak, nonatomic) IBOutlet UITextField *positionField;

@property (weak, nonatomic) IBOutlet UIButton *expertInCategoriesButton;
@property (weak, nonatomic) IBOutlet UIButton *loogingForExpertsInCategoriesButton;

- (IBAction)expertInCategories:(id)sender;
- (IBAction)lookingForExpertsInCategories:(id)sender;

- (IBAction)registerNewUser:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

- (void) setProfileDataOnView: (User *) user;
-(void) saveUserCategories: (NSString *) userId accessToken: (NSString *) accessToken;

@end