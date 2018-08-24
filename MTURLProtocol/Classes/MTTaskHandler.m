//
//  MTTaskHandler.m
//  AFNetworking
//
//  Created by bigyelow on 2018/8/24.
//

#import "MTTaskHandler.h"

@implementation MTTaskHandler

- (BOOL)canHandleTask:(NSURLSessionTask *)task
{
  NSAssert(NO, @"Subclass should implement this method");
  return NO;
}

- (NSURLSessionTask *)decoratedTaskForTask:(NSURLSessionTask *)task
{
  NSAssert(NO, @"Subclass should implement this method");
  return task;
}

@end
