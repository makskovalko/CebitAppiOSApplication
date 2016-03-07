//
//  PasswordGenerator.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 24.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "PasswordGenerator.h"

@implementation PasswordGenerator

+(NSString *) generatePassword {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity: 10];
    for (int i = 0; i < 10; i++)
        [result appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    return result;
}

@end