//
//  NSURLRequest+Utils.m
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import "NSURLRequest+Utils.h"
#import "MTURLRequestSerialization.h"

@implementation NSURLRequest (Utils)

- (NSURLRequest *)requestByAddingHeaders:(NSDictionary *)headers parameters:(NSDictionary *)params
{
  if (!headers.count && !params.count) {
    return self;
  }

  NSMutableURLRequest *mutReq = self.mutableCopy;
  [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]){
      [mutReq setValue:obj forHTTPHeaderField:key];
    }
  }];

  NSMutableDictionary *mutParams = params.mutableCopy;
  [self _mt_addQuery:self.URL.query toParameters:mutParams];

  NSURLComponents *comp = [[NSURLComponents alloc] initWithURL:self.URL resolvingAgainstBaseURL:NO];
  comp.query = nil;
  mutReq.URL = comp.URL;

  MTHTTPRequestSerializer *serializer = [[MTHTTPRequestSerializer alloc] init];
  return [serializer requestBySerializingRequest:mutReq
                                  withParameters:params
                                           error:nil];
}

- (BOOL)isHTTPSeries
{
  return [@[@"http", @"https"] containsObject:self.URL.scheme.lowercaseString];
}

#pragma mark - Helpers

- (void)_mt_addQuery:(NSString *)query toParameters:(NSMutableDictionary *)parameters
{
  if (!parameters) {
    return;
  }

  for (NSString *pair in [query componentsSeparatedByString:@"&"]) {
    NSArray *keyValuePair = [pair componentsSeparatedByString:@"="];
    if (keyValuePair.count != 2) {
      continue;
    }

    NSString *key = [keyValuePair[0] stringByRemovingPercentEncoding];
    if (parameters[key] == nil) {
      parameters[key] = [keyValuePair[1] stringByRemovingPercentEncoding];
    }
  }
}

@end
