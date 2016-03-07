//
//  Category.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 21.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "Categories.h"

@implementation Categories

- (Categories *) init: (NSInteger *) categoryId name: (NSString *) name {
    self.categoryId = categoryId;
    self.name = name;
    
    return self;
}

- (Categories *) init {
    return self;
}

@end