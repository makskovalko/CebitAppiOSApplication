//
//  HttpRequestsWorker.h
//  CeBitApplication
//
//  Created by Maxim Kovalko on 19.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestsWorker : NSObject

+ (NSDictionary *) getDataFrom:(NSString *) url;

@end
