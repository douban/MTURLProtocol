//
//  MTURLSessionDataTaskDemux.h
//  FRDNetwork
//
//  Created by XueMing on 14/03/2017.
//  Copyright (c) 2017 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSURLSessionDataTask 分发器，当在 NSURLProtocol 中创建 NSURLSessionDataTask 时，使用这个分发器进行创建，
 以存储每个 data task 所关联的 thread 和 delegate。
 */
@interface MTURLSessionDataTaskDemux : NSObject

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration;

@property (nonatomic, copy,   readonly) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong, readonly) NSURLSession *session;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     delegate:(id<NSURLSessionDataDelegate>)delegate
                                        modes:(nullable NSArray *)modes;

@end

NS_ASSUME_NONNULL_END
