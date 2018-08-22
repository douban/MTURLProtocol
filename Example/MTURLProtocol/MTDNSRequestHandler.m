//
//  MTDNSRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import FRDNetwork;

#import "MTDNSRequestHandler.h"

@implementation MTDNSRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  NSURL *URL = [request URL];
  if (URL == nil) {
    return NO;
  }

  if (![FRDDNSConfiguration URLProtocolEnabled]) {
    return NO;
  }

  NSString *URLScheme = [URL scheme];
  NSString *URLHost = [URL host];
  if ([URLScheme length] == 0 ||
      [URLHost length] == 0 ||
      [@[@"http", @"https"] containsObject:URLScheme.lowercaseString] == NO) {
    return NO;
  }

  id<FRDDNSResolver> resolver = [FRDDNSConfiguration DNSResolverForHost:URLHost];
  if (resolver != nil && [resolver isKindOfClass:[FRDDNSPodHTTPDNSResolver class]]) {
    FRDDNSPodHTTPDNSResolver *httpdnsResolver = (FRDDNSPodHTTPDNSResolver *)resolver;
    FRDDNSCacheEntry *cacheEntry = [httpdnsResolver cacheResultForHost:URLHost];

    if ([[cacheEntry addresses] count] == 0 || ![cacheEntry isValid]) {
      [httpdnsResolver syncFromServerForHost:URLHost completionHandler:nil];
      return NO;
    }

    if ([[cacheEntry addresses] count] > 0) {
      return YES;
    }
  }

  return NO;
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
