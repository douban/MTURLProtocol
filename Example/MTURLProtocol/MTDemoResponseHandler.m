//
//  MTDemoResponseHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/23.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import MTURLProtocol;

#import "MTDemoResponseHandler.h"
#import "NSURLRequest+MT.h"

@implementation MTDemoResponseHandler

- (BOOL)shouldHandleRequest:(NSURLRequest *)request
{
  return [request mt_isRXRRemoteRequest] || [request mt_isDNSRequest];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler
{
  if (self.client != nil && self.dataTask == task) {
    NSMutableURLRequest *mutableRequest = [self.dataTask.currentRequest mutableCopy];
    [mutableRequest setURL:request.URL];
    completionHandler(mutableRequest);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  if (self.client != nil && (self.dataTask == nil || self.dataTask == task)) {
    if (error == nil) {
      [self.client URLProtocolDidFinishLoading:self.protocol];
    } else if ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
      // Do nothing.
    } else {
      // Here we don't call `URLProtocol:didFailWithError:` method because browser may not be able to handle `error`
      // object correctly. Instead we return HTTP response manually and you can handle this response easily
      // in rexxar-web (https://github.com/douban/rexxar-web). In addition, we alse leave chance for
      // native code to handle the error through `rxr_handleError:fromReporter:` method.
      NSHTTPURLResponse *response = [NSHTTPURLResponse mt_responseWithURL:task.currentRequest.URL
                                                               statusCode:999
                                                             headerFields:nil
                                                          noAccessControl:YES];

      [self.client URLProtocol:self.protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
  }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  if (self.client != nil && self.dataTask != nil && self.dataTask == dataTask) {
    NSHTTPURLResponse *URLResponse = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
      URLResponse = (NSHTTPURLResponse *)response;
      URLResponse = [NSHTTPURLResponse mt_responseWithURL:URLResponse.URL
                                               statusCode:URLResponse.statusCode
                                             headerFields:URLResponse.allHeaderFields
                                          noAccessControl:YES];
    }

    [self.client URLProtocol:self.protocol
            didReceiveResponse:URLResponse ?: response
            cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
  if (self.client != nil && self.dataTask == dataTask) {
    [self.client URLProtocol:self.protocol didLoadData:data];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *_Nullable cachedResponse))completionHandler
{
  if (self.client != nil && self.dataTask == dataTask) {
    completionHandler(proposedResponse);
  }
}

@end
