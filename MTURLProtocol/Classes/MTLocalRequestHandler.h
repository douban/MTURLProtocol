//
//  MTLocalRequestHandler.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import "MTRequestHandler.h"

@interface MTLocalRequestHandler : MTRequestHandler

- (nullable NSURLResponse *)responseForRequest:(NSURLRequest *)request;
- (nullable NSData *)responseData;

@end
