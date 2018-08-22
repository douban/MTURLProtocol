//
//  MTRXRRemoteRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import "MTRXRRemoteRequestHandler.h"

@implementation MTRXRRemoteRequestHandler

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  // frodo.douban.com/<jsonp|api>/ 为 API AJAX 请求。
  if ([request.URL.scheme isEqualToString:@"https"]) {
    if ([request.URL.host isEqualToString:@"frodo.douban.com"] && ([request.URL.path hasPrefix:@"/jsonp/"] || [request.URL.path hasPrefix:@"/api/"])) {
      return YES;
    }
    else if ([request.URL.host isEqualToString:@"read.douban.com"] && [request.URL.path hasPrefix:@"/j/"]) {
      return YES;
    }
  }

  return NO;
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  NSAssert(NO, @"Subclass should implement this method");
  return NO;
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  NSAssert(NO, @"Subclass should implement this method");
  return request;
}

@end
