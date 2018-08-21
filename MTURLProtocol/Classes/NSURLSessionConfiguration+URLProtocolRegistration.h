//
//  NSURLSessionConfiguration+RKURLProtocolRegistration.h
//  ReaderKit
//
//  Created by Chongyu Zhu on 5/27/16.
//  Copyright © 2016 Beijing Ark Reading Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionConfiguration (URLProtocolRegistration)

- (BOOL)mt_registerProtocolClass:(Class)protocolClass;
- (void)mt_unregisterProtocolClass:(Class)protocolClass;

@end

NS_ASSUME_NONNULL_END
