//
//  CategoriesViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 25.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@property (nonatomic, strong) NSMutableArray *selectedRows;

@end

@implementation CategoriesViewController {
    NSArray *categories;
    NSMutableArray *expertInCategories;
    NSArray *searchResults;
}

@synthesize tableView;
@synthesize searchBar;
@synthesize selectedRows = _selectedRows;

- (NSMutableArray *)selectedRows {
    if (_selectedRows == nil) {
        _selectedRows = [[NSMutableArray alloc] init];
    }
    return _selectedRows;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    expertInCategories = [NSMutableArray arrayWithArray: (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"expertInCategories"]];
    
    categories = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"categories"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSelectedRows];
    [tableView reloadData];
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self updateSelectedRows];
//    [tableView reloadData];
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else return [categories count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: simpleTableIdentifier forIndexPath: indexPath];
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *expertInCategories = (NSMutableArray *)[cache objectForKey: @"expertInCategories"];


    if ([self selectedRowContains:indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }   else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchResults  objectAtIndex: indexPath.row][@"name"];
    } else {
        cell.textLabel.text = [categories objectAtIndex: indexPath.row][@"name"];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *cachedExpertInCategories = (NSMutableArray *)[cache objectForKey: @"expertInCategories"];
    
    NSMutableDictionary *object = (NSMutableDictionary *)[categories objectAtIndex: indexPath.row];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: object];
    [dict setObject: [NSNumber numberWithInteger: indexPath.row] forKey: @"index"];
    
    if ([self selectedRowContains:indexPath.row]) {
        [expertInCategories removeObject: dict];
        [self removeSelected:indexPath.row];
        NSLog(@"%@", expertInCategories);
    }
    else {
        [expertInCategories addObject: dict];
        [self.selectedRows addObject:[NSNumber numberWithInt:indexPath.row]];
        NSLog(@"%@", expertInCategories);
    }
    
    [tableView reloadData];
}


-(void)updateSelectedRows {
        for (NSDictionary *cat in expertInCategories) {
            NSNumber *number = cat[@"index"];
            [self.selectedRows addObject:[NSNumber numberWithInt:[number intValue]]];
        }
}

-(BOOL)selectedRowContains:(int) index {
    for (NSNumber *number in self.selectedRows) {
        if ([number intValue] == index) {
            return YES;
        }
    }
    return NO;
}

-(void)removeSelected:(int) index {
    
    id numberToDelete = nil;
    
    for (NSNumber *number in self.selectedRows) {
        if ([number intValue] == index) {
            numberToDelete = number;
        }
    }
    
    [self.selectedRows removeObject:numberToDelete];
    
}


-(void) filterContentForSearchText: (NSString *) searchText scope: (NSString *) scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat: @"SELF contains[cd] %@", searchText];
    searchResults = [categories filteredArrayUsingPredicate: resultPredicate];
    [self.tableView reloadData];
}

-(BOOL) searchDisplayController: (UISearchDisplayController *) controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText: searchString scope: [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex: [self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


//Back Button Pressed - save categories to cache

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject: self] == NSNotFound) {
        NSLog(@"Back Button pressed!");
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        [cache removeObjectForKey: @"expertInCategories"];
        [cache setObject: expertInCategories forKey: @"expertInCategories"];
        [cache synchronize];
        //NSLog(@"%@", expertInCategories);
    }
    [super viewWillDisappear: animated];
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