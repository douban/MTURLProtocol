//
//  MTURLSessionDataTaskDemux.m
//  FRDNetwork
//
//  Created by XueMing on 14/03/2017.
//  Copyright (c) 2017 Douban Inc. All rights reserved.
//

#import "MTURLSessionDataTaskDemux.h"
#import "MTURLSessionDataTaskInfo.h"

@interface MTURLSessionDataTaskDemux () <NSURLSessionDataDelegate>

@property (nonatomic, copy  ) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSMutableDictionary *taskInfoRecorder;

@end

@implementation MTURLSessionDataTaskDemux

- (instancetype)init
{
  return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration
{
  self = [super init];
  if (self) {
    NSString *sessionName = [NSString stringWithFormat:@"%@.%@.%p.URLSession", [[NSBundle mainBundle] bundleIdentifier], NSStringFromClass([self class]), self];
    NSString *delegateQueueName = [NSString stringWithFormat:@"%@.delegateQueue", sessionName];

    _sessionConfiguration = [sessionConfiguration copy];
    _taskInfoRecorder = [NSMutableDictionary dictionary];
    _sessionDelegateQueue = [[NSOperationQueue alloc] init];
    _sessionDelegateQueue.maxConcurrentOperationCount = 4;
    _sessionDelegateQueue.name = delegateQueueName;
    _session = [NSURLSession sessionWithConfiguration:_sessionConfiguration delegate:self delegateQueue:_sessionDelegateQueue];
    _session.sessionDescription = sessionName;
  }
  return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     delegate:(id<NSURLSessionDataDelegate>)delegate
                                        modes:(nullable NSArray *)modes
{
  if ([modes count] == 0) {
    modes = @[NSDefaultRunLoopMode];
  }

  NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request];
  MTURLSessionDataTaskInfo *taskInfo = [[MTURLSessionDataTaskInfo alloc] initWithTaskID:dataTask.taskIdentifier delegate:delegate modes:modes];

  @synchronized (self) {
    _taskInfoRecorder[@([dataTask taskIdentifier])] = taskInfo;
  }

  return dataTask;
}

#pragma mark - Private Methods

- (MTURLSessionDataTaskInfo *)_frd_taskInfoForTask:(NSURLSessionTask *)task
{
  MTURLSessionDataTaskInfo *taskInfo = nil;

  @synchronized (self) {
    taskInfo = [self.taskInfoRecorder objectForKey:@([task taskIdentifier])];
  }

  return taskInfo;
}

#pragma mark - URLSession serires'd elegates

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)newRequest
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:task];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler];
    }];
  } else {
    completionHandler(newRequest);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:task];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    }];
  } else {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:task];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:needNewBodyStream:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session task:task needNewBodyStream:completionHandler];
    }];
  } else {
    completionHandler(nil);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:task];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }];
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:task];

  @synchronized (self) {
    [self.taskInfoRecorder removeObjectForKey:@(taskInfo.taskID)];
  }

  // Call the delegate if required. In that case we invalidate the task info on the client thread
  // after calling the delegate, otherwise the client thread side of the -performBlock: code can
  // find itself with an invalidated task info.
  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session task:task didCompleteWithError:error];
      [taskInfo invalidate];
    }];
  } else {
    [taskInfo invalidate];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:dataTask];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }];
  } else {
    completionHandler(NSURLSessionResponseAllow);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:dataTask];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
    }];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:dataTask];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveData:data];
    }];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
  MTURLSessionDataTaskInfo *taskInfo = [self _frd_taskInfoForTask:dataTask];

  if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
    [taskInfo performBlock:^{
      [taskInfo.delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    }];
  } else {
    completionHandler(proposedResponse);
  }
}

@end
