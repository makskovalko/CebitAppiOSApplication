//
//  DialogsViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 29.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "DialogsViewController.h"
#import "AFNetworking.h"
#import "DialogsTableCell.h"
#import <MGSwipeTableCell/MGSwipeButton.h>
#import "UIColor+Additions.h"
#import <QMServices.h>
#import <Quickblox/Quickblox.h>
#import "ChatViewController.h"
#import "DialogsTableCell.h"

@interface DialogsViewController ()

@end

@implementation DialogsViewController {
    NSMutableArray *dialogs;
    NSMutableArray *filteredTableData;
    BOOL *isFiltered;
}

@synthesize tableView;
@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    searchBar.delegate = (id)self;
    
    [self getAllDialogs];
}

-(void) getAllDialogs {
   
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
    
    [QBRequest dialogsForPage:page extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        dialogs = dialogObjects;
        [self.tableView reloadData];
    } errorBlock:^(QBResponse *response) {
        
    }];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) isFiltered = NO;
    else {
        isFiltered = YES;
        filteredTableData = [[NSMutableArray alloc] init];
        for (QBChatDialog *item in dialogs) {
            NSRange nameRange = [item.name rangeOfString: searchText options: NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) [filteredTableData addObject: item];
        }
    }
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isFiltered ? [filteredTableData count] : [dialogs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DialogsTableCell";
    DialogsTableCell *rawCell = (DialogsTableCell *) [self.tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath: indexPath];
    if (rawCell == nil){
        rawCell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }

    QBChatDialog *dialog = (QBChatDialog *) (isFiltered ? [filteredTableData objectAtIndex: indexPath.row] : [dialogs objectAtIndex: indexPath.row]);
        NSMutableArray* mutableOccupants = [dialog.occupantIDs mutableCopy];
    if (QMServicesManager.instance.currentUser != nil && QMServicesManager.instance.currentUser.ID >0) {
        [mutableOccupants removeObject:@(QMServicesManager.instance.currentUser.ID)];
    }
    
        NSNumber* opponentID = [mutableOccupants firstObject];

    [QBRequest userWithID:opponentID.integerValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        if (opponentID.integerValue == user.ID) {
            rawCell.nameLabel.text = user.fullName;
            UIImage *meImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: user.website]]];
            rawCell.avatarImage.image = meImage;
                    }
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Error:ChatViewController:startChat errorBlock response=%@",response);
    }];
    [rawCell.avatarImage setContentMode:UIViewContentModeScaleAspectFill];
    rawCell.avatarImage.layer.masksToBounds = YES;
    rawCell.nameLabel.text = dialog.name != nil&& ![dialog.name isEqualToString:[NSString stringWithFormat:@"%ld",(long)dialog.recipientID]]?dialog.name:@"";
    rawCell.lastmessageLabel.text = dialog.lastMessageText != nil?dialog.lastMessageText:@"";
    rawCell.avatarImage.layer.cornerRadius = 21;
    rawCell.avatarImage.layer.masksToBounds = YES;
    
    return rawCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatDialog *dialog = (QBChatDialog *) (isFiltered ? [filteredTableData objectAtIndex: indexPath.row] : [dialogs objectAtIndex: indexPath.row]);
    NSMutableArray* mutableOccupants = [dialog.occupantIDs mutableCopy];
    if (QMServicesManager.instance.currentUser != nil && QMServicesManager.instance.currentUser.ID >0) {
        [mutableOccupants removeObject:@(QMServicesManager.instance.currentUser.ID)];
    }
    NSNumber* opponentID = [mutableOccupants firstObject];
    [QBRequest userWithID:opponentID.integerValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        if (user&&user.ID>0){
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            controller.dialog = dialog;
            controller.opponentUser = user;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            NSLog(@"Error:MatchScreenViewController:startChat response=%@",response);
        }
        
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Error:MatchScreenViewController:startChat errorBlock response=%@",response);
        
    } ];
}

@end