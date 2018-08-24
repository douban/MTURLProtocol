//
//  MTTaskHandler.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MTTaskHandler : NSObject

- (BOOL)canHandleTask:(NSURLSessionTask *)task;
- (NSURLSessionTask *)decoratedTaskForTask:(NSURLSessionTask *)task;

@end
NS_ASSUME_NONNULL_END
