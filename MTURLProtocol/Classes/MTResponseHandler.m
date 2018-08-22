//
//  MTResponseHandler.m
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import "MTResponseHandler.h"

@implementation MTResponseHandler

- (BOOL)shouldHandleRequest:(NSURLRequest *)request
{
  NSAssert(NO, @"Subclass should implement this method");
  return NO;
}

@end
