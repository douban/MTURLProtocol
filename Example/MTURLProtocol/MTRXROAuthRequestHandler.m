//
//  MTRXROAuthRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import DOUFoundation;
@import FRDFangorn;
@import AdSupport;
#import "MTRXROAuthRequestHandler.h"

@implementation MTRXROAuthRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self canInitWithRequest:request];
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  /// Headers
  // token
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  NSString *token = [[[DOUAccountManager currentAccount] oauth] accessToken];
  if (token) {
    [headers setObject:[@"Bearer " stringByAppendingString:token] forKey:@"Authorization"];
  }

  // user agent
  NSString *userAgent;
  if ([RXRConfig externalUserAgent]) {
    userAgent = [UserAgentHelper userAgentByAppendingComponents:@[[RXRConfig externalUserAgent]] toOriginalUA:[UserAgentHelper userAgentFrom:request]];
  }

  userAgent = [UserAgentHelper userAgentByAppendingString:[self _mt_currentNetworkStatusStr] toOriginalUA:userAgent];

  if (userAgent.length > 0) {
    [headers setObject:userAgent forKey:@"User-Agent"];
  }

  /// Parameters
  NSString *eventLocID = [[[FRDLocationManager sharedInstance] eventLocation] identifier] ?: @"";
  NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString ?: @"";
  NSMutableDictionary *parameters = [@{@"loc_id": eventLocID,
                                       @"apikey": [FRDSecrets appKey],
                                       @"_need_webp": @"0",
                                       @"udid": [DOUSharedUDID sharedUDID],
                                       @"douban_udid": [DOUSharedUDID sharedUDIDForDoubanApplications],
                                       @"dumpling": idfa} mutableCopy];

  NSArray *queryItems = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL: NO].queryItems;
  for (NSURLQueryItem *queryItem in queryItems) {
    NSString *key = [queryItem.name stringByRemovingPercentEncoding];
    NSString *value = [queryItem.value stringByRemovingPercentEncoding];
    parameters[key] = value;
  }

  return [request mt_requestByAddingHeaders:headers parameters:parameters];
}

- (NSString *)_mt_currentNetworkStatusStr
{
  NetworkStatus status = [[DOUNetworkReachability sharedReachability] currentStatus];
  NSString *statusStr = @"unknown";
  switch (status) {
    case ReachableViaWiFi:
      statusStr = @"wifi";
      break;
    case ReachableViaWWAN:
      statusStr = @"wwan";
      break;
    default:
      break;
  }
  return [NSString stringWithFormat:@"network/%@", statusStr];
}

@end
