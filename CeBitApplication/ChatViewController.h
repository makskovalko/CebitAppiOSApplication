//
//  ChatViewController.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 29.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSUserDefaults+DemoSettings.h"
#import "QMChatViewController.h"

@interface ChatViewController : QMChatViewController

@property (nonatomic, strong) QBChatDialog* dialog;
@property (nonatomic, strong) QBUUser* opponentUser;
//@property (nonatomic, strong) NSArray* items;
@property (nonatomic, assign) BOOL shouldUpdateNavigationStack;

@end