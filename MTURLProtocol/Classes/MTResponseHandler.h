//
//  MTResponseHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MTResponseHandler : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

- (BOOL)shouldHandleRequest:(NSURLRequest *)request;

@end
NS_ASSUME_NONNULL_END
