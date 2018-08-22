//
//  MTRequestHandler.m
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import "MTRequestHandler.h"

@implementation MTRequestHandler

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  NSAssert(NO, @"Subclass should implement this method");
  return NO;
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request
{
  NSAssert(NO, @"Subclass should implement this method");
  return request;
}

@end