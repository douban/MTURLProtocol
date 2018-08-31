//
//  MTTestLocalRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/31.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import "MTTestLocalRequestHandler.h"

@implementation MTTestLocalRequestHandler

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [request.URL.path containsString:@"local-api"];
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self.class canInitWithRequest:originalRequest];
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return request;
}

- (NSData *)responseData
{
  NSDictionary *dict = @{@"text": @"hello world"};

  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  return jsonData;
}

- (NSURLResponse *)responseForRequest:(NSURLRequest *)request
{
  return [NSHTTPURLResponse mt_responseWithURL:request.URL
                                    statusCode:200
                                  headerFields:nil
                               noAccessControl:YES];
}

@end
