//
//  MTLocalRequestHandler.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import "MTRequestHandler.h"

/**
 Used when it should return response without sending request to server. Usually, response and related data may be returned from local.
 */
@protocol MTLocalRequestHandler <MTRequestHandler>

- (nullable NSURLResponse *)responseForRequest:(NSURLRequest *)request;
- (nullable NSData *)responseData;

@end
