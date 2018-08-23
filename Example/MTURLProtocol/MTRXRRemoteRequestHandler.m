//
//  MTRXRRemoteRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import "MTRXRRemoteRequestHandler.h"
#import "NSURLRequest+MT.h"

@implementation MTRXRRemoteRequestHandler

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [request mt_isRXRRemoteRequest];
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
