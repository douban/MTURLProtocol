//
//  NSURLSessionConfiguration+RKURLProtocolRegistration.m
//  ReaderKit
//
//  Created by Chongyu Zhu on 5/27/16.
//  Copyright © 2016 Beijing Ark Reading Technology Co., Ltd. All rights reserved.
//

#import "NSURLSessionConfiguration+URLProtocolRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSURLSessionConfiguration (URLProtocolRegistration)

- (BOOL)mt_registerProtocolClass:(Class)protocolClass
{
  NSParameterAssert(protocolClass != Nil);

  if (![protocolClass isSubclassOfClass:[NSURLProtocol class]]) {
    return NO;
  }

  NSArray<Class> *const protocolClasses = [self protocolClasses];

  if (protocolClasses != nil) {
    NSMutableArray<Class> *const mutableProtocolClasses = [protocolClasses mutableCopy];
    [mutableProtocolClasses insertObject:protocolClass atIndex:0];

    [self setProtocolClasses:mutableProtocolClasses];
  } else {
    [self setProtocolClasses:@[protocolClass]];
  }

  return YES;
}

- (void)mt_unregisterProtocolClass:(Class)protocolClass
{
  NSParameterAssert(protocolClass != Nil);

  if (![protocolClass isSubclassOfClass:[NSURLProtocol class]]) {
    return;
  }

  NSArray<Class> *const protocolClasses = [self protocolClasses];

  if (protocolClasses != nil && [protocolClasses count] > 0) {
    NSMutableArray<Class> *const mutableProtocolClasses = [protocolClasses mutableCopy];
    [mutableProtocolClasses removeObjectIdenticalTo:protocolClass];

    [self setProtocolClasses:mutableProtocolClasses];
  }
}

@end

NS_ASSUME_NONNULL_END
