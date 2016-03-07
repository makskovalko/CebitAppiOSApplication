//
//  User.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 18.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property NSUInteger *userId;
@property NSString *name, *email, *country, *city, *phoneNumber, *profileImage, *about, *placeOfWork, *position, *accessToken;
@property NSString *authorizationType;

-(User *) init;
- (NSString*) convertToJSON:(id) object;
- (NSString *) toString;

@end