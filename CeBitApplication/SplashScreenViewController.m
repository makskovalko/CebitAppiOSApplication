//
//  SplashScreenViewController.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 22.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "FLAnimatedImage.h"
#import "User.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController {
    NSTimer *myTimer;
    float currentProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = screen.size.width;
    CGFloat height = screen.size.height;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"brain_trnsp" withExtension:@".gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    
    CGFloat posX = width / 2 - 100;
    CGFloat posY = height / 2 - 100;
    
    imageView.frame = CGRectMake(posX, posY, 200, 200);
    [self.view addSubview:imageView];
    
    currentProgress = 0;
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)updateProgress
{
    if(currentProgress >= 100){
        [myTimer invalidate];
        
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];
        if (user != nil) [self performSegueWithIdentifier: @"userProfile" sender: nil];
        else [self performSegueWithIdentifier: @"loginSegue" sender: self];
    } else{
        currentProgress += 3;
        [_progressBar setProgress:currentProgress animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"loginSegue"]) {
        NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
        //User *user = (User *)[cache objectForKey: @"user"];
    }
}

@end