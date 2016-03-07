//
//  UIColor+Additions.h
//  Factor
//
//  Created by Evgeniy Tka4enko on 09.05.14.
//  Copyright (c) 2014 vexadev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorFromStringsRGBHex:(NSString*)hex;
+ (UIColor *)colorFromStringsRGBHex:(NSString*)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorFromColorsPlist:(NSString*)colorName;
+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorFromColorsPlist:(NSString*)colorName alpha:(CGFloat)alpha;
- (NSUInteger)RGBHex;


@end
