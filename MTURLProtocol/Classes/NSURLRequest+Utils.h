//
//  NSURLRequest+Utils.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Utils)

- (NSURLRequest *)requestByAddingHeaders:(nullable NSDictionary *)headers parameters:(nullable NSDictionary *)params;
- (BOOL)isHTTPSeries;

@end
