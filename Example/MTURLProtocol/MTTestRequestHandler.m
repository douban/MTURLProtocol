//
//  MTTestRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/31.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import "MTTestRequestHandler.h"

@implementation MTTestRequestHandler

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [request.URL.absoluteString isEqualToString:@"https://jsonplaceholder.typicode.com/"];
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self.class canInitWithRequest:originalRequest];
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  NSMutableURLRequest *mutReq = request.mutableCopy;
  NSURLComponents *comp = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
  comp.path = @"/todos/1";
  mutReq.URL = comp.URL;
  return mutReq;
}

@end
