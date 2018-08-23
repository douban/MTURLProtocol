//
//  NSURLRequest+Utils.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/22.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Utils)

- (NSURLRequest *)mt_requestByAddingHeaders:(nullable NSDictionary *)headers parameters:(nullable NSDictionary *)params;
- (BOOL)mt_isHTTPSeries;

@end
