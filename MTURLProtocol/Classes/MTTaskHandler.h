//
//  MTTaskHandler.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Subclass this class if needed.
 Used to decorate MTURLProtocol instance's dataTask(NSURLSessionTask) before sending decoated request.
 */
@interface MTTaskHandler : NSObject

/**
 Check if can handle the task.

 - Note: Only one handler will be chose to handle the task. You may exend this function to support multiple MTTaskHandler
 instances.
 */
- (BOOL)canHandleTask:(NSURLSessionTask *)task;
- (NSURLSessionTask *)decoratedTaskForTask:(NSURLSessionTask *)task;

@end
NS_ASSUME_NONNULL_END
