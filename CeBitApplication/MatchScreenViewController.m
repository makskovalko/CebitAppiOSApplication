//
//  MatchScreenViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 26.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "MatchScreenViewController.h"
#import "ChatViewController.h"
#import <QMServices.h>

@interface MatchScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *meProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *matchProfileImage;
@property (weak, nonatomic) QBChatDialog *matchedDialog;
@property (strong, nonatomic) QBUUser * opponentUser;
- (IBAction)startChat:(id)sender;
- (IBAction)moveOn:(id)sender;

@end

@implementation MatchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *recipientUser = (NSMutableDictionary *)[cache objectForKey: @"recipientUser"];
    NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];
    
    self.connectionLabel.text = [NSString stringWithFormat: @"%@ %@", recipientUser[@"name"], self.connectionLabel.text];
    
    UIImage *meImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: user[@"profile_image"]]]];
    self.meProfileImage.image = meImage;
    self.meProfileImage.layer.masksToBounds = YES;
    
    UIImage *matchProfile = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: recipientUser[@"profile_image"]]]];
    self.matchProfileImage.image = matchProfile;
    self.matchProfileImage.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"startChat"]) {
        ChatViewController *chatController = [segue destinationViewController];
        chatController.dialog = _matchedDialog;
        chatController.opponentUser = _opponentUser;
    }
}


- (IBAction)startChat:(id)sender {
    [sender setEnabled:NO];
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];
    NSMutableDictionary *matchedUser = (NSMutableDictionary *)[cache objectForKey: @"recipientUser"];
    [QBRequest userWithExternalID:((NSNumber *) matchedUser[@"id"]).intValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        if (user&&user.ID>0){
            _opponentUser = user;
            [QMServicesManager.instance.chatService createPrivateChatDialogWithOpponent:user completion:^(QBResponse *response, QBChatDialog *createdDialog) {
                
                if (createdDialog != nil) {
                    _matchedDialog = createdDialog;
                    [self performSegueWithIdentifier:@"startChat" sender:self];
                }else{
                    _opponentUser = nil;
                    [sender setEnabled:YES];NSLog(@"Error:MatchScreenViewController:startChat response=%@",response);
                }
                [sender setEnabled:YES];
            }];
        }else{
            [sender setEnabled:YES];
            NSLog(@"Error:MatchScreenViewController:startChat response=%@",response);
        }
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Error:MatchScreenViewController:startChat errorBlock response=%@",response);
        [sender setEnabled:YES];
    }];

}

- (IBAction)moveOn:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
}
@end