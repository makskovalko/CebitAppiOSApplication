//
//  DashboardViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 06.03.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "DashboardViewController.h"
#import "FLAnimatedImage.h"
#import "AFNetworking.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController {
    NSArray *connections;
}

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = screen.size.width;
    CGFloat height = screen.size.height;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"brain-dash" withExtension:@".gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    [imageView setContentMode: UIViewContentModeScaleAspectFit];
    imageView.animatedImage = image;
    [self.imageView setImage: imageView.image];
    
    UIImage *imageViewImage = self.imageView.image;
    
    /*imageView.frame = CGRectMake(-width / 4, 0, self.imageView.frame.size.width + self.imageView.frame.size.width / 3, self.imageView.frame.size.height + self.imageView.frame.size.height / 3);*/
    
    /*imageView.frame = CGRectMake(-self.imageView.frame.size.width / 2, -imageViewImage.size.height / 2 + 7, self.imageView.frame.size.width + self.imageView.frame.size.width / 2 + 10, self.imageView.frame.size.height + self.imageView.frame.size.height / 2);*/
    
    [self.imageView addSubview: imageView];
    
    //imageView.frame = CGRectMake(self.imageView.frame.size.width / 2, 0, self.imageView.frame.size.width + self.imageView.frame.size.width / 2, self.imageView.frame.size.height + self.imageView.frame.size.height / 2);
    
    //[self.imageView insertSubview: imageView aboveSubview: self.imageView];
    
    //[self getAllConnections];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self getCountByURL: @"neurons" textLabel: self.countNeuronsLabel];
    [self getCountByURL: @"matches/count" textLabel: self.countMatchesLabel];
    [self getAllConnections];
}

-(void) getAllConnections {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey: @"user"];
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@matches/%@", apiURL, user[@"id"]];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];
    [manager GET: requestURL parameters: nil progress: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *matches = (NSArray *)responseObject;
        NSLog(@"Connections: %@", connections);
        connections = matches;
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void) getCountByURL: (NSString *) url textLabel: (UILabel *) label {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey: @"user"];
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, url];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];
    [manager GET: requestURL parameters: nil progress: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        label.text = [NSString stringWithFormat: @"%@", responseObject[@"count"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [connections count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SimpeTableCell" forIndexPath: indexPath];
    cell.textLabel.text = [connections objectAtIndex: indexPath.row][@"user"][@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ in %@", [connections objectAtIndex: indexPath.row][@"user"][@"position"], [connections objectAtIndex: indexPath.row][@"user"][@"place_of_work"]];
    cell.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [connections objectAtIndex: indexPath.row][@"user"][@"profile_image"]]]];
    [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
    cell.imageView.layer.masksToBounds = YES;
    cell.indentationWidth = 5;
    cell.indentationLevel = 5;
    
    cell.imageView.layer.cornerRadius = 38;//cell.imageView.frame.size.width / 2;
    return cell;
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
