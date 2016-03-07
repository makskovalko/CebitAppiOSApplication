//
//  HttpRequestsWorker.m
//  CeBitApplication
//
//  Created by Maxim Kovalko on 19.02.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import "HttpRequestsWorker.h"

@implementation HttpRequestsWorker

+ (NSDictionary *) getDataFrom:(NSString *)url {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData: oResponseData
                                                             options:0
                                                               error:nil];
    
    
    if([responseCode statusCode] != 200){
        return nil;
    }
    
    return jsonData;
}

@end