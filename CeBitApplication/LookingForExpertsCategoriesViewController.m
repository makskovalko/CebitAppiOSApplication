//
//  LookingForExpertsCategoriesViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 25.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "LookingForExpertsCategoriesViewController.h"

@interface LookingForExpertsCategoriesViewController ()

@property (nonatomic, strong) NSMutableArray *selectedRows;


@end

@implementation LookingForExpertsCategoriesViewController {
    NSArray *categories;
    NSMutableArray *lookingForExperts;
    NSArray *searchResults;
}

@synthesize selectedRows = _selectedRows;

- (NSMutableArray *)selectedRows {
    if (_selectedRows == nil) {
        _selectedRows = [[NSMutableArray alloc] init];
    }
    return _selectedRows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    lookingForExperts = [NSMutableArray arrayWithArray: (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"lookingForExperts"]];
    categories = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"categories"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSelectedRows];
    [self.tableView reloadData];
}

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
    NSMutableArray *expertInCategories = (NSMutableArray *)[cache objectForKey: @"lookingForExperts"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: simpleTableIdentifier];
    }
    
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *cachedExpertInCategories = (NSMutableArray *)[cache objectForKey: @"lookingForExperts"];
    
    NSMutableDictionary *object = (NSMutableDictionary *)[categories objectAtIndex: indexPath.row];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: object];
    [dict setObject: [NSNumber numberWithInteger: indexPath.row] forKey: @"index"];
    
    if ([self selectedRowContains:indexPath.row]) {
        [lookingForExperts removeObject: dict];
        [self removeSelected:indexPath.row];
    }
    else {
        [lookingForExperts addObject: dict];
        [self.selectedRows addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    
    [tableView reloadData];
    
//    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//        NSMutableDictionary *object = (NSMutableDictionary *)[categories objectAtIndex: indexPath.row];
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: object];
//        [dict setObject: [NSNumber numberWithInteger: indexPath.row] forKey: @"index"];
//        
//        [lookingForExperts removeObject: dict];
//        NSLog(@"%@", lookingForExperts);
//    }
//    else {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        NSMutableDictionary *object = (NSMutableDictionary *)[categories objectAtIndex: indexPath.row];
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: object];
//        [dict setObject: [NSNumber numberWithInteger: indexPath.row] forKey: @"index"];
//        [lookingForExperts addObject: dict];
//        NSLog(@"%@", lookingForExperts);
//    }
}

-(void)updateSelectedRows {
    for (NSDictionary *cat in lookingForExperts) {
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
        [cache removeObjectForKey: @"lookingForExperts"];
        [cache setObject: lookingForExperts forKey: @"lookingForExperts"];
        [cache synchronize];
        //NSLog(@"%@", expertInCategories);
    }
    [super viewWillDisappear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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