//
//  DialogsViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 29.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end
