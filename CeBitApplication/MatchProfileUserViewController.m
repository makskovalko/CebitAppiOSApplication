//
//  MatchUserViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 29.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "MatchProfileUserViewController.h"

@interface MatchProfileUserViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *expertsInLabel;
@property (weak, nonatomic) IBOutlet UILabel *lookingForExpertsLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeOfWorkLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;


@property (weak, nonatomic) IBOutlet UIView *UserInfoView;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MatchProfileUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = (NSDictionary *)[cache objectForKey: @"matchUserProfile"];
    NSLog(@"%@", user);
    
    UIImage *img = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: user[@"profile_image"]]]];
    
    self.profileImageView.layer.masksToBounds = YES;
    [self.profileImageView setImage: img];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.name.text = (user[@"name"] != nil && ![user[@"name"] isEqualToString: @""]) ? user[@"name"] : @"No data";
    self.emailLabel.text = (user[@"email"] != nil && ![user[@"email"] isEqualToString: @""]) ? user[@"email"] : @"No data";
    self.countryLabel.text = (user[@"country"] != nil && ![user[@"country"] isEqualToString: @""]) ? user[@"country"] : @"No data";
    self.placeOfWorkLabel.text = (user[@"place_of_work"] != nil && ![user[@"place_of_work"] isEqualToString: @""]) ? user[@"place_of_work"] : @"No data";
    self.positionLabel.text = (user[@"position"] != nil && ![user[@"position"] isEqualToString: @""]) ? user[@"position"] : @"No data";
    
    NSLog(@"Match user profile");
    
    NSLog(@"%@", user[@"expertInCategories"]);
    NSLog(@"%@", user[@"lookingForExperts"]);
    
    NSMutableArray *expertInCategories = user[@"expertInCategories"];
    NSMutableArray *lookingForExperts = user[@"lookingForExperts"];
    
    NSMutableArray *expCatLabels = [[NSMutableArray alloc] init];
    NSMutableArray *lookingCatLabels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [expertInCategories count]; i++)
        [expCatLabels addObject: [expertInCategories objectAtIndex: i][@"name"]];
    
    for (int i = 0; i < [lookingForExperts count]; i++)
        [lookingCatLabels addObject: [lookingForExperts objectAtIndex: i][@"name"]];
    
    NSString *expertCategories = [expCatLabels componentsJoinedByString: @", "];
    NSString *lookingCategories = [lookingCatLabels componentsJoinedByString: @", "];
    
    NSString *expertString = [NSString stringWithFormat: @"%@ %@", self.expertsInLabel.text, [expertInCategories count] == 0 ? @"No selected categories" : expertCategories];
    NSString *lookingString = [NSString stringWithFormat: @"%@ %@", self.lookingForExpertsLabel.text, [lookingForExperts count] == 0 ? @"No selected categories" : lookingCategories];
    
    
    NSMutableAttributedString *expString = [[NSMutableAttributedString alloc] initWithString: expertString];
    [expString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range: NSMakeRange([expertString rangeOfString: @":"].location + 1, expertCategories.length + 1)];
    self.expertsInLabel.attributedText = expString;
    
    NSMutableAttributedString *lookStr = [[NSMutableAttributedString alloc] initWithString: lookingString];
    [lookStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range: NSMakeRange([lookingString rangeOfString: @":"].location + 1, lookingCategories.length + 1)];
    
    self.lookingForExpertsLabel.attributedText = lookStr;
    
    NSLog(@"User's categories: %@", expertInCategories);
    NSLog(@"Looking for categories: %@", lookingForExperts);

    
    self.aboutLabel.text = (user[@"about"] != nil && ![user[@"about"] isEqualToString: @""]) ? user[@"about"] : @"No data";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    self.UserInfoView.layer.borderColor = [UIColor grayColor].CGColor;
    self.UserInfoView.layer.borderWidth = 0.5f;
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