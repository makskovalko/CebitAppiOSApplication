//
//  SplashScreenViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 22.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@interface SplashScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end