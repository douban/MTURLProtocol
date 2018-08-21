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

static NSArray<id<MTRequestHandler>> *_requestHandlers;

@interface MTURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *dataTask;
@property (nonatomic, copy) NSArray *modes;

@end

@implementation MTURLProtocol

+ (MTURLSessionDataTaskDemux *)sharedDemux
{
  static dispatch_once_t onceToken;
  static MTURLSessionDataTaskDemux *demux;

  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setTimeoutIntervalForRequest:15];
    [sessionConfiguration mt_registerProtocolClass:[self class]];
    demux = [[MTURLSessionDataTaskDemux alloc] initWithSessionConfiguration:sessionConfiguration];
  });

  return demux;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
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
  // Config runloop mode
  NSMutableArray *modes = [NSMutableArray array];
  [modes addObject:NSDefaultRunLoopMode];
  NSString *currentMode = [[NSRunLoop currentRunLoop] currentMode];
  if (currentMode != nil && ![currentMode isEqualToString:NSDefaultRunLoopMode]) {
    [modes addObject:currentMode];
  }
  self.modes = modes;

  // Decorate request and generate dataTask
  NSURLSessionTask *dataTask = [[[self class] sharedDemux] dataTaskWithRequest:[self _mt_decoratedRequestOfRequest:self.request]
                                                                      delegate:self
                                                                         modes:self.modes];
  [dataTask resume];
  self.dataTask = dataTask;
}

- (void)stopLoading
{
  if (_dataTask != nil) {
    [_dataTask cancel];
    self.dataTask = nil;
  }
}

#pragma mark - Properties

+ (NSArray<id<MTRequestHandler>> *)requestHandlers
{
  return _requestHandlers;
}

+ (void)setRequestHandlers:(NSArray<id<MTRequestHandler>> *)requestHandlers
{
  _requestHandlers = [requestHandlers copy];
}

#pragma mark - Helpers

- (NSURLRequest *)_mt_decoratedRequestOfRequest:(NSURLRequest *)request
{
  for (id handlers in self.class.requestHandlers) {
    if ([handlers canInitWithRequest:request]) {
      request = [handlers decoratedRequestOfRequest:request];
    }
  }
  return request;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler
{

}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler
{
  
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{

}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *_Nullable cachedResponse))completionHandler
{

}

@end
