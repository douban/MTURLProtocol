//
//  MTTestResponseHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/31.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import "MTTestResponseHandler.h"

@implementation MTTestResponseHandler

- (BOOL)shouldHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [originalRequest.URL.path containsString:@"remote-api"];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler
{
  if (_client != nil && _dataTask == task) {
    NSMutableURLRequest *mutableRequest = [_dataTask.currentRequest mutableCopy];
    [mutableRequest setURL:request.URL];
    completionHandler(mutableRequest);
  }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  if (_client != nil && (_dataTask == nil || _dataTask == task)) {
    if (error == nil) {
      [_client URLProtocolDidFinishLoading:self.protocol];
    } else if ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
      // Do nothing.
    } else {
      NSHTTPURLResponse *response = [NSHTTPURLResponse  mt_responseWithURL:task.currentRequest.URL
                                                                statusCode:999
                                                              headerFields:nil
                                                           noAccessControl:YES];

      [_client URLProtocol:self.protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
  }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  if (_client != nil && _dataTask != nil && _dataTask == dataTask) {
    NSHTTPURLResponse *URLResponse = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
      URLResponse = (NSHTTPURLResponse *)response;
      URLResponse = [NSHTTPURLResponse mt_responseWithURL:URLResponse.URL
                                               statusCode:URLResponse.statusCode
                                             headerFields:URLResponse.allHeaderFields
                                          noAccessControl:YES];
    }

    [_client URLProtocol:self.protocol
      didReceiveResponse:URLResponse ?: response
      cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
  if (_client != nil && _dataTask == dataTask) {
    [_client URLProtocol:self.protocol didLoadData:data];
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *_Nullable cachedResponse))completionHandler
{
  if (_client != nil && _dataTask == dataTask) {
    completionHandler(proposedResponse);
  }
}

@end
