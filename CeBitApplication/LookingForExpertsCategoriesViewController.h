//
//  LookingForExpertsCategoriesViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 25.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LookingForExpertsCategoriesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end