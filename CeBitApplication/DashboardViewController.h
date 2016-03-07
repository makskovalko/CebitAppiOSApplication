//
//  DashboardViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 06.03.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *countNeuronsLabel;
@property (weak, nonatomic) IBOutlet UILabel *countMatchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *countChatsLabel;

@end