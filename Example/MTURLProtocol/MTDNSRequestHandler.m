//
//  MTDNSRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import FRDNetwork;
#import "MTDNSRequestHandler.h"
#import "NSURLRequest+MT.h"

@implementation MTDNSRequestHandler

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [request mt_isDNSRequest];
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self canInitWithRequest:request];
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  NSArray<NSString *> *addresses = nil;

  id<FRDDNSResolver> resolver = [FRDDNSConfiguration DNSResolverForHost:request.URL.host];
  if ([resolver isKindOfClass:[FRDDNSPodHTTPDNSResolver class]]) {
    FRDDNSPodHTTPDNSResolver *httpdnsResolver = (FRDDNSPodHTTPDNSResolver *)resolver;
    FRDDNSCacheEntry *cacheEntry = [httpdnsResolver cacheResultForHost:request.URL.host];
    addresses = [cacheEntry addresses];
  }

  if (addresses.count > 0) {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    NSString *originalHost = [mutableRequest valueForHTTPHeaderField:@"Host"];
    if (originalHost.length == 0) {
      [mutableRequest setValue:[URLComponents host] forHTTPHeaderField:@"Host"];
    }

    URLComponents.host = addresses.frd_anyObject;
    mutableRequest.URL = URLComponents.URL;
    return mutableRequest;
  }

  return request;
}

@end
