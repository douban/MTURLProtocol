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

static NSArray<Class<MTRequestHandler>> *_requestHandlers;
static NSArray<Class<MTResponseHandler>> *_responseHandlers;
static NSArray<Class<MTTaskHandler>> *_taskHandlers;

@interface MTURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *dataTask;
@property (nonatomic, copy) NSArray *modes;
@property (nonatomic, copy) NSURLRequest *originalRequest;  // The request before decorated.
@property (nonatomic, copy) NSURLRequest *finalRequest; // The request before sent.

@property (nonatomic, copy) NSArray<id<MTRequestHandler>> *requestHandlers;
@property (nonatomic, copy) NSArray<id<MTResponseHandler>> *responseHandlers;
@property (nonatomic, copy) NSArray<id<MTTaskHandler>> *taskHandlers;
@property (nonatomic, strong) id<MTLocalRequestHandler> localRequestHandler;
@property (nonatomic, readonly, nullable) id<MTResponseHandler> responseHandler;

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

  // The request will be intercepted if any handler can init with it.
  for (Class<MTRequestHandler> hd in self.requestHandlers) {
    if ([hd canInitWithRequest:request]) {
      return YES;
    }
  }
  return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                 cachedResponse:(NSCachedURLResponse *)cachedResponse
                         client:(id<NSURLProtocolClient>)client
{
  if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
    [self _mt_initHandlers];
  }
  return self;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task
              cachedResponse:(NSCachedURLResponse *)cachedResponse
                      client:(id<NSURLProtocolClient>)client
{
  if (self = [super initWithTask:task cachedResponse:cachedResponse client:client]) {
    [self _mt_initHandlers];
  }
  return self;
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

  // Decorate request. If is a local request, will assign a localRequestHandler.
  NSURLRequest *newRequest = [self _mt_decoratedRequestOfRequest:self.request];
  self.finalRequest = newRequest;

  // Check is local or remote request
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

    // Check if need decorate dataTask
    id<MTTaskHandler> handler = [self _mt_taskHandlerForTask:dataTask];
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

  if ([self.responseHandler respondsToSelector:@selector(stopLoading)]) {
    [self.responseHandler stopLoading];
  }
}

#pragma mark - Public Methods

+ (void)addRequestHandler:(Class<MTRequestHandler>)handler
{
  [self setRequestHandlers:[self _mt_addHandler:handler toArray:[self requestHandlers]]];
}

+ (void)removeRequestHandler:(Class<MTResponseHandler>)handler
{
  [self setRequestHandlers:[self _mt_removeHandler:handler ofArray:[self requestHandlers]]];
}

+ (void)addResponseHandler:(Class<MTResponseHandler>)handler
{
  [self setResponseHandlers:[self _mt_addHandler:handler toArray:[self responseHandlers]]];
}

+ (void)removeResponseHandler:(Class<MTResponseHandler>)handler
{
  [self setResponseHandlers:[self _mt_removeHandler:handler ofArray:[self responseHandlers]]];
}

+ (void)addTaskHandler:(Class<MTTaskHandler>)handler
{
  [self setTaskHandlers:[self _mt_addHandler:handler toArray:[self taskHandlers]]];
}

+ (void)removeTaskHandler:(Class<MTTaskHandler>)handler
{
  [self setTaskHandlers:[self _mt_removeHandler:handler ofArray:[self taskHandlers]]];
}

#pragma mark - Properties

+ (NSArray<Class<MTRequestHandler>> *)requestHandlers
{
  return _requestHandlers;
}

+ (void)setRequestHandlers:(NSArray<Class<MTRequestHandler>> *)requestHandlers
{
  _requestHandlers = requestHandlers.copy;
}

+ (NSArray<Class<MTResponseHandler>> *)responseHandlers
{
  return _responseHandlers;
}

+ (void)setResponseHandlers:(NSArray<Class<MTResponseHandler>> *)responseHandlers
{
  _responseHandlers = responseHandlers.copy;
}

+ (NSArray<Class<MTTaskHandler>> *)taskHandlers
{
  return _taskHandlers;
}

+ (void)setTaskHandlers:(NSArray<Class<MTTaskHandler>> *)taskHandlers
{
  _taskHandlers = taskHandlers.copy;
}

/**
 Only one reponseHandler will be chose regarding to original request and final request.
 */
- (id<MTResponseHandler>)responseHandler
{
  for (id<MTResponseHandler> handler in self.responseHandlers) {
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

- (void)_mt_initHandlers
{
  NSMutableArray *requestHandlers = [NSMutableArray array];
  for (Class class in [self.class requestHandlers]) {
    [requestHandlers addObject:[class new]];
  }
  _requestHandlers = requestHandlers.copy;

  NSMutableArray *responseHandler = [NSMutableArray array];
  for (Class class in [self.class responseHandlers]) {
    [responseHandler addObject:[class new]];
  }
  _responseHandlers = responseHandler.copy;

  NSMutableArray *taskHandlers = [NSMutableArray array];
  for (Class class in [self.class taskHandlers]) {
    [taskHandlers addObject:[class new]];
  }
  _taskHandlers = taskHandlers.copy;
}

- (NSURLRequest *)_mt_decoratedRequestOfRequest:(NSURLRequest *)request
{
  NSURLRequest *newRequest = request;
  for (id<MTRequestHandler> handler in self.requestHandlers) {
    if ([handler canHandleRequest:newRequest originalRequest:request]) {
      newRequest = [handler decoratedRequestOfRequest:newRequest originalRequest:request];

      // Return instantly if is a local request
      if ([handler conformsToProtocol:@protocol(MTLocalRequestHandler)]) {
        self.localRequestHandler = (id<MTLocalRequestHandler>)handler;
        return newRequest;
      }
    }
  }
  return newRequest;
}

- (nullable id<MTTaskHandler>)_mt_taskHandlerForTask:(NSURLSessionTask *)task
{
  for (id<MTTaskHandler> handler in self.taskHandlers) {
    if ([handler canHandleTask:task]) {
      return handler;
    }
  }

  return nil;
}

+ (NSArray *)_mt_addHandler:(Class)handler toArray:(NSArray *)array
{
  BOOL added = NO;
  for (Class hd in array) {
    if (hd == handler) {
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

+ (NSArray *)_mt_removeHandler:(Class)handler ofArray:(NSArray *)array
{
  if ([array containsObject:handler]) {
    NSMutableArray *mutArray = array.mutableCopy;
    [mutArray removeObject:handler];
    return mutArray;
  }
  else {
    return array;
  }
}

+ (NSURLCacheStoragePolicy)_mt_storagePolicyForRequest:(NSURLRequest *)request response:(NSURLResponse *)response
{
  if (!request || !response) {
    NSAssert(NO, @"Should not be here");
    return NSURLCacheStorageNotAllowed;
  }

  if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
    return NSURLCacheStorageNotAllowed;
  }

  NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
  switch ([HTTPResponse statusCode]) {
    case 200:
    case 203:
    case 206:
    case 301:
    case 304:
    case 404:
    case 410:
      break;
    default:
      return NSURLCacheStorageNotAllowed;
      break;
  }

  NSString *responseHeader = [[HTTPResponse allHeaderFields][@"Cache-Control"] lowercaseString];
  if (responseHeader != nil && [responseHeader rangeOfString:@"no-store"].location != NSNotFound) {
    return NSURLCacheStorageNotAllowed;
  }

  NSString *requestHeader = [[request allHTTPHeaderFields][@"Cache-Control"] lowercaseString];
  if (requestHeader != nil
      && [requestHeader rangeOfString:@"no-store"].location != NSNotFound
      && [requestHeader rangeOfString:@"no-cache"].location != NSNotFound) {
    return NSURLCacheStorageNotAllowed;
  }

  return NSURLCacheStorageAllowed;
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
  else if (task == _dataTask) {
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
  else if (task == _dataTask) {
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
  else if (task == _dataTask) {
    if (error == nil) {
      [self.client URLProtocolDidFinishLoading:self];
    }
    else {
      [self.client URLProtocol:self didFailWithError:error];
    }
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
  else if (task == _dataTask) {
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
  else if (dataTask == _dataTask) {
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:[self.class _mt_storagePolicyForRequest:dataTask.originalRequest response:response]];
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
  else if (dataTask == _dataTask) {
    [self.client URLProtocol:self didLoadData:data];
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
  else if (dataTask == _dataTask) {
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
