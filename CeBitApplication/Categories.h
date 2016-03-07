//
//  Category.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 21.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Categories : NSObject

@property NSInteger *categoryId;
@property NSString *name;

- (Categories *) init: (NSInteger *) categoryId name: (NSString *) name;

@end