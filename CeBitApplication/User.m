//
//  User.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 18.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "User.h"

@implementation User

- (User *) init {
    return self;
}

- (User *) initWithParams:(NSString *) name email: (NSString *) email profileImage: (NSString *) profileImage country: (NSString *) country city: (NSString *) city {
    
    self.name = name;
    self.email = email;
    self.profileImage = profileImage;
    self.country = country;
    self.city = city;
    
    return self;
}

- (NSString *) toString {
    return [NSString stringWithFormat: @"Name: %@\nE-mail: %@\nProfile image: %@\nCountry: %@\nCity: %@",
            self.name, self.email, self.profileImage, self.country, self.city];
}

-(NSString*) convertToJSON:(id) object
{
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end