//
//  MTRXRAccountRequestHandler.m
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/22.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import MTURLProtocol;
@import FRDFangorn;
#import "MTRXRAccountRequestHandler.h"
#import "NSURLRequest+MT.h"

@implementation MTRXRAccountRequestHandler

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [request mt_isRXRAccountLocalRequest];
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self canInitWithRequest:request];
}

- (NSURLResponse *)responseForRequest:(NSURLRequest *)request
{
  return [NSHTTPURLResponse rxr_responseWithURL:request.URL
                                     statusCode:[DOUAccountManager currentUser] ? 200 : 403
                                   headerFields:nil
                                noAccessControl:YES];
}

- (NSData *)responseData
{
  NSDictionary *dict;
  if ([DOUAccountManager currentUser]) {
    dict = [DOUAccountManager currentUser].dictionary;
  }
  else {
    dict = @{
             @"msg": @"need_login",
             @"code": @(103),
             @"request": @"GET /v2/~me",
             @"localized_message": @""
             };
  }

  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  return jsonData;
}

@end
