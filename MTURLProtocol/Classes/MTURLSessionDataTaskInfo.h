//
//  MTURLSessionDataTaskInfo.h
//  DOUFoundation
//
//  Created by bigyelow on 2018/5/19.
//

#import <Foundation/Foundation.h>

/**
 记录 NSURLSessionDataTask 实例关联的 thread 和 delegate
 */
@interface MTURLSessionDataTaskInfo : NSObject

- (instancetype)initWithTaskID:(NSUInteger)taskID delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes;

@property (nonatomic, readonly) NSUInteger taskID;
@property (nonatomic, weak, readonly) id<NSURLSessionDataDelegate> delegate;

/**
 在关联的 thread 上执行指定的 block
 */
- (void)performBlock:(dispatch_block_t)block;

- (void)invalidate;

@end
