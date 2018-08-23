//
//  NSURLRequest+MT.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/23.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import FRDNetwork;
@import MTURLProtocol;
#import "NSURLRequest+MT.h"

@implementation NSURLRequest (MT)

- (BOOL)mt_isDNSRequest
{
  NSURL *URL = [self URL];
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

- (BOOL)mt_isRXRRemoteRequest
{
  // frodo.douban.com/<jsonp|api>/ 为 API AJAX 请求。
  if ([self.URL.scheme isEqualToString:@"https"]) {
    if ([self.URL.host isEqualToString:@"frodo.douban.com"] && ([self.URL.path hasPrefix:@"/jsonp/"] || [self.URL.path hasPrefix:@"/api/"])) {
      return YES;
    }
    else if ([self.URL.host isEqualToString:@"read.douban.com"] && [self.URL.path hasPrefix:@"/j/"]) {
      return YES;
    }
  }

  return NO;
}

- (BOOL)mt_isRXRAccountLocalRequest
{
  // https://frodo.douban.com/api/v2/~me
  if ([self mt_isHTTPSeries] &&
      [self.URL.host isEqualToString:@"frodo.douban.com"] &&
      [self.URL.path hasPrefix:@"/api/v2/~me"]) {
    return YES;
  }
  return NO;
}

@end
