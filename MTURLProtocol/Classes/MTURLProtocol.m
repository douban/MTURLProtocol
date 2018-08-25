//
//  MTURLProtocol.m
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import "MTURLProtocol.h"
#import "MTURLSessionDataTaskDemux.h"
#import "NSURLSessionConfiguration+URLProtocolRegistration.h"
#import "MTRequestHandler.h"
#import "MTResponseHandler.h"
#import "MTLocalRequestHandler.h"
#import "MTTaskHandler.h"

static NSArray<MTRequestHandler *> *_requestHandlers;
static NSArray<MTResponseHandler *> *_responseHandlers;
static NSArray<MTTaskHandler *> *_taskHandlers;

@interface MTURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *dataTask;
@property (nonatomic, copy) NSArray *modes;
@property (nonatomic, strong) MTLocalRequestHandler *localRequestHandler;
@property (nonatomic, readonly, nullable) MTResponseHandler *responseHandler;
@property (nonatomic, copy) NSURLRequest *originalRequest;
@property (nonatomic, copy) NSURLRequest *finalRequest;

@end

@implementation MTURLProtocol

+ (MTURLSessionDataTaskDemux *)sharedDemux
{
  static dispatch_once_t onceToken;
  static MTURLSessionDataTaskDemux *demux;

  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:15];
    demux = [[MTURLSessionDataTaskDemux alloc] initWithSessionConfiguration:sessionConfiguration];
  });

  return demux;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  NSLog(@"MTURLProtocol canInitWithRequest = %@", request.URL.absoluteString);

  // If any handler of self.requestHandlers can init, it should return YES.
  for (id handler in self.requestHandlers) {
    if ([handler canInitWithRequest:request]) {
      return YES;
    }
  }
  return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (void)startLoading
{
  // Init
  self.localRequestHandler = nil;
  self.originalRequest = self.request;
  self.finalRequest = self.request;

  // Config runloop mode
  NSMutableArray *modes = [NSMutableArray array];
  [modes addObject:NSDefaultRunLoopMode];
  NSString *currentMode = [[NSRunLoop currentRunLoop] currentMode];
  if (currentMode != nil && ![currentMode isEqualToString:NSDefaultRunLoopMode]) {
    [modes addObject:currentMode];
  }
  self.modes = modes;

  // Decorate request and check if is local or remote request.
  NSURLRequest *newRequest = [self _mt_decoratedRequestOfRequest:self.request];
  self.finalRequest = newRequest;
  if (_localRequestHandler) {
    NSLog(@"MTURLProtocol startLoading local request = %@", newRequest.URL.absoluteString);

    NSData *data = [_localRequestHandler responseData];
    NSURLResponse *response = [_localRequestHandler responseForRequest:newRequest];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
  }
  else {
    NSLog(@"MTURLProtocol startLoading remote request = %@", newRequest.URL.absoluteString);

    NSURLSessionTask *dataTask = [self.class.sharedDemux dataTaskWithRequest:newRequest
                                                                    delegate:self
                                                                       modes:self.modes];

    MTTaskHandler *handler = [self _mt_taskHandlerForTask:dataTask];
    if (handler) {
      dataTask = [handler decoratedTaskForTask:dataTask];
    }

    [dataTask resume];
    self.dataTask = dataTask;
  }
}

- (void)stopLoading
{
  if (_dataTask != nil) {
    [_dataTask cancel];
    self.dataTask = nil;
  }

  [self.responseHandler stopLoading];
}

#pragma mark - Public Methods

+ (void)addRequestHandler:(MTRequestHandler *)handler
{
   [self setRequestHandlers:[self _mt_addHandler:handler toArray:[self requestHandlers]]];
}

+ (void)removeRequestHandler:(MTRequestHandler *)handler
{
  [self setRequestHandlers:[self _mt_removeHandler:handler ofArray:[self requestHandlers]]];
}

+ (void)removeRequestHandlerByClass:(Class)class
{
  [self setRequestHandlers:[self _mt_removeHandlerByClass:class ofArray:[self requestHandlers]]];
}

+ (void)addResponseHandler:(MTResponseHandler *)handler
{
  [self setResponseHandlers:[self _mt_addHandler:handler toArray:[self responseHandlers]]];
}

+ (void)removeResponseHandler:(MTResponseHandler *)handler
{
  [self setResponseHandlers:[self _mt_removeHandler:handler ofArray:[self responseHandlers]]];
}

+ (void)removeResponseHandlerByClass:(Class)class
{
  [self setResponseHandlers:[self _mt_removeHandlerByClass:class ofArray:[self responseHandlers]]];
}

+ (void)addTaskHandler:(MTTaskHandler *)handler
{
  [self setTaskHandlers:[self _mt_addHandler:handler toArray:[self taskHandlers]]];
}

+ (void)removeTaskHandler:(MTTaskHandler *)handler
{
  [self setTaskHandlers:[self _mt_removeHandler:handler ofArray:[self taskHandlers]]];
}

+ (void)removeTaskHandlerByClass:(Class)class
{
  [self setTaskHandlers:[self _mt_removeHandlerByClass:class ofArray:[self taskHandlers]]];
}

#pragma mark - Properties

+ (NSArray<MTRequestHandler *> *)requestHandlers
{
  return _requestHandlers;
}

+ (void)setRequestHandlers:(NSArray<MTRequestHandler *> *)requestHandlers
{
  _requestHandlers = [requestHandlers copy];
}

+ (NSArray<MTResponseHandler *> *)responseHandlers
{
  return _responseHandlers;
}

+ (void)setResponseHandlers:(NSArray<MTResponseHandler *> *)responseHandlers
{
  _responseHandlers = [responseHandlers copy];
}

+ (NSArray<MTTaskHandler *> *)taskHandlers
{
  return _taskHandlers;
}

+ (void)setTaskHandlers:(NSArray<MTTaskHandler *> *)taskHandlers
{
  _taskHandlers = [taskHandlers copy];
}

- (MTResponseHandler *)responseHandler
{
  for (MTResponseHandler *handler in [self.class responseHandlers]) {
    if ([handler shouldHandleRequest:_finalRequest originalRequest:_originalRequest]) {
      handler.client = self.client;
      handler.protocol = self;
      handler.dataTask = _dataTask;
      return handler;
    }
  }
  return nil;
}

#pragma mark - Helpers

- (NSURLRequest *)_mt_decoratedRequestOfRequest:(NSURLRequest *)request
{
  NSURLRequest *newRequest = request;
  for (MTRequestHandler *handler in self.class.requestHandlers) {
    if ([handler canHandleRequest:newRequest originalRequest:request]) {
      newRequest = [handler decoratedRequestOfRequest:newRequest originalRequest:request];

      if ([handler isKindOfClass:MTLocalRequestHandler.class]) {
        self.localRequestHandler = (MTLocalRequestHandler *)handler;
        return newRequest;
      }
    }
  }
  return newRequest;
}

- (nullable MTTaskHandler *)_mt_taskHandlerForTask:(NSURLSessionTask *)task
{
  for (MTTaskHandler *handler in [self.class taskHandlers]) {
    if ([handler canHandleTask:task]) {
      return handler;
    }
  }

  return nil;
}

+ (NSArray *)_mt_addHandler:(NSObject *)handler toArray:(NSArray *)array
{
  if (!handler) {
    return array;
  }

  BOOL added = NO;
  for (NSObject *hd in array) {
    if ([hd isKindOfClass:handler.class]) { // Only add one instance of the specific class
      added = YES;
      break;
    }
  }

  if (added) {
    return array;
  }

  NSMutableArray *mutArray = array.mutableCopy;
  if (!mutArray) {
    mutArray = [NSMutableArray array];
  }
  [mutArray addObject:handler];
  return mutArray;
}

+ (NSArray *)_mt_removeHandler:(NSObject *)handler ofArray:(NSArray *)array
{
  if (!handler) {
    return array;
  }

  if ([array containsObject:handler]) {
    NSMutableArray *mutArray = array.mutableCopy;
    [mutArray removeObject:handler];
    return mutArray;
  }
  else {
    return array;
  }
}

+ (NSArray *)_mt_removeHandlerByClass:(Class)class ofArray:(NSArray *)array
{
  NSObject *removingHandler;
  for (NSObject *handler in array) {
    if ([handler isKindOfClass:class]) {
      removingHandler = handler;
      break;
    }
  }

  if (removingHandler) {
    NSMutableArray *mutArray = array.mutableCopy;
    [mutArray removeObject:removingHandler];
    return mutArray;
  }
  else {
    return array;
  }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
    [self.responseHandler URLSession:session
                                task:task
          willPerformHTTPRedirection:response
                          newRequest:request
                   completionHandler:completionHandler];
  }
  else {
    completionHandler(request);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
    [self.responseHandler URLSession:session
                                task:task
                 didReceiveChallenge:challenge
                   completionHandler:completionHandler];
  }
  else {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
    [self.responseHandler URLSession:session
                                task:task
                didCompleteWithError:error];
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:needNewBodyStream:)]) {
    [self.responseHandler URLSession:session
                                task:task
                   needNewBodyStream:completionHandler];
  }
  else {
    completionHandler(nil);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
    [self.responseHandler URLSession:session
                                task:task
                     didSendBodyData:bytesSent
                      totalBytesSent:totalBytesSent
            totalBytesExpectedToSend:totalBytesExpectedToSend];
  }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)])  {
    [self.responseHandler URLSession:session
                            dataTask:dataTask
                  didReceiveResponse:response
                   completionHandler:completionHandler];
  }
  else {
    completionHandler(NSURLSessionResponseAllow);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
    [self.responseHandler URLSession:session
                            dataTask:dataTask
                      didReceiveData:data];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *_Nullable cachedResponse))completionHandler
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
    [self.responseHandler URLSession:session
                            dataTask:dataTask
                   willCacheResponse:proposedResponse
                   completionHandler:completionHandler];
  }
  else {
    completionHandler(proposedResponse);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)]) {
    [self.responseHandler URLSession:session
                            dataTask:dataTask
               didBecomeDownloadTask:downloadTask];
  }
}

@end
