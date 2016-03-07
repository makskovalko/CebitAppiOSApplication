//
//  UIColor+Additions.m
//  Factor
//
//  Created by Evgeniy Tka4enko on 09.05.14.
//  Copyright (c) 2014 vexadev. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

- (UIColor *)lighterColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
    {
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    }
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
    {
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    }
    return nil;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    return [self colorWithRGBHex:hex alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

- (NSUInteger)RGBHex
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    NSInteger ired, igreen, iblue;
    ired = roundf(red * 255);
    igreen = roundf(green * 255);
    iblue = roundf(blue * 255);
    NSUInteger result = (ired << 16) | (igreen << 8) | iblue;
    return result;
}

+ (UIColor *)colorFromStringsRGBHex:(NSString*)hex{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)colorFromStringsRGBHex:(NSString*)hex alpha:(CGFloat)alpha{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

+ (UIColor *)colorFromColorsPlist:(NSString*)colorName{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Colors" ofType:@"plist"];
    NSString *color =[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:colorName];
    if (color) {
        return [UIColor colorFromStringsRGBHex:color];
    }
    return [UIColor blackColor];
}

+ (UIColor *)colorFromColorsPlist:(NSString*)colorName alpha:(CGFloat)alpha{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Colors" ofType:@"plist"];
    NSString *color =[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:colorName];
    if (color) {
        return [UIColor colorFromStringsRGBHex:color alpha:alpha];
    }
    return [UIColor blackColor];
}


@end
