//
//  MTLocalRequestHandler.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import "MTRequestHandler.h"

/**
 Used when should reture response without network traverse. Response and response data may be returned from local.
 */
@protocol MTLocalRequestHandler <MTRequestHandler>

- (nullable NSURLResponse *)responseForRequest:(NSURLRequest *)request;
- (nullable NSData *)responseData;

@end
