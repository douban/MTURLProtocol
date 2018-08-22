//
//  MTLocalRequestHandler.m
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import "MTLocalRequestHandler.h"

@implementation MTLocalRequestHandler

- (NSURLResponse *)responseForRequest:(NSURLRequest *)request
{
  NSAssert(NO, @"Subclass should implement this method");
  return nil;
}

- (NSData *)responseData
{
  NSAssert(NO, @"Subclass should implement this method");
  return nil;
}

@end
