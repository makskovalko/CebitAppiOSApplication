#import "MatchingController.h"
#import "DraggableViewBackground.h"
#import "AFNetworking.h"

@interface MatchingController ()
@end

@implementation MatchingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
[[self navigationController] setNavigationBarHidden:YES animated:YES];

    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = screen.size.width;
    CGFloat height = screen.size.height;
    
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(0, height / 2 + 50, width, height)];
    [paintView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:paintView];
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
    [self.view bringSubviewToFront: draggableBackground];
    
    UIButton *brainCenterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, height - 50, width, 50)];
    [brainCenterBtn setTitle: @"BRAIN CENTER" forState: UIControlStateNormal];
    brainCenterBtn.backgroundColor = [UIColor colorWithRed:0.965 green:0.820 blue:0.173 alpha:1.00];
    [brainCenterBtn setFont: [UIFont fontWithName: @"Hevletica" size: 15.0]];
    brainCenterBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    [brainCenterBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    
    UIImageView *brainIcon = [[UIImageView alloc] initWithFrame: CGRectMake(width / 2 - 20, height - 75, 51, 44)];
    UIImage *brainImage = [UIImage imageNamed: @"brain-center"];
    [brainIcon setImage:brainImage];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openDashboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [brainCenterBtn addTarget: self action: @selector(openDashboard) forControlEvents: UIControlEventTouchUpInside];
    
    [brainIcon setUserInteractionEnabled: YES];
    [brainIcon addGestureRecognizer: gestureRecognizer];
    
    [self.view addSubview: brainCenterBtn];
    [self.view addSubview: brainIcon];
    //[self getUsersForMatch];
    
}

-(void) openDashboard {
    NSLog(@"Dashboard");
    [self performSegueWithIdentifier: @"showDashboard" sender: self];
}

-(void) getUsersForMatch {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *lookingForExperts = [NSMutableArray arrayWithArray: (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"expertInCategories"]];
    NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];

    NSLog(@"Categories for match: %@", lookingForExperts);
    NSLog(@"User: %@", user);
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"matches/%@", user[@"id"]]];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    NSMutableArray *matchCategories = [NSMutableArray array];
    for (int i = 0; i < [lookingForExperts count]; i++)
        [matchCategories addObject: [lookingForExperts objectAtIndex: i][@"id"]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];

    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject: matchCategories forKey: @"categories"];
    
    [manager POST:requestURL parameters: userData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
        NSMutableArray *responseUser = (NSMutableArray *) responseObject;
        NSLog(@"%@", responseUser);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden: YES];
    //[self.view sendSubviewToBack: self.imageView];
}

@end