//
//  MTURLProtocol.m
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import "MTURLProtocol.h"
#import "MTURLSessionDataTaskDemux.h"
#import "NSURLSessionConfiguration+URLProtocolRegistration.h"

static NSString *const LoadedKey = @"LoadedKey";

@interface MTURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *dataTask;
@property (nonatomic, strong) NSRecursiveLock *lock;
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
  return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (void)startLoading
{
  NSMutableArray *modes = [NSMutableArray array];
  [modes addObject:NSDefaultRunLoopMode];

  NSString *currentMode = [[NSRunLoop currentRunLoop] currentMode];
  if (currentMode != nil && ![currentMode isEqualToString:NSDefaultRunLoopMode]) {
    [modes addObject:currentMode];
  }
  self.modes = modes;

  NSURLSessionTask *dataTask = [[[self class] sharedDemux] dataTaskWithRequest:self.request delegate:self modes:self.modes];
  [dataTask resume];
  [self setDataTask:dataTask];}

- (void)stopLoading
{
  if (_dataTask != nil) {
    [_dataTask cancel];
    self.dataTask = nil;
  }
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
