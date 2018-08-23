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

static NSArray<MTRequestHandler *> *_requestHandlers;
static NSArray<MTResponseHandler *> *_responseHandlers;

@interface MTURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *dataTask;
@property (nonatomic, copy) NSArray *modes;
@property (nonatomic, strong) MTLocalRequestHandler *localRequestHandler;
@property (nonatomic, readonly, nullable) MTResponseHandler *responseHandler;
@property (nonatomic, strong) NSURLRequest *originalRequest;

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
  // Check if there is any local request handler
  self.localRequestHandler = nil;
  self.originalRequest = self.request;

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
  if (_localRequestHandler) {
    NSData *data = [_localRequestHandler responseData];
    NSURLResponse *response = [_localRequestHandler responseForRequest:newRequest];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
  }
  else {
    NSURLSessionTask *dataTask = [self.class.sharedDemux dataTaskWithRequest:newRequest
                                                                    delegate:self
                                                                       modes:self.modes];
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

+ (void)makeRegistered
{
  [self.class.sharedDemux.sessionConfiguration mt_registerProtocolClass:self.class];
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

- (MTResponseHandler *)responseHandler
{
  for (MTResponseHandler *handler in [self.class responseHandlers]) {
    if ([handler shouldHandleRequest:_originalRequest]) {
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
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  if ([self.responseHandler respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
    [self.responseHandler URLSession:session
                                task:task
                didCompleteWithError:error];
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
}

@end
