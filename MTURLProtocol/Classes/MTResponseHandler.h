//
//  MTResponseHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>
@class MTURLProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface MTResponseHandler : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak) id<NSURLProtocolClient> client;
@property (nonatomic, weak) NSURLSessionTask *dataTask;
@property (nonatomic, weak) MTURLProtocol *protocol;

- (BOOL)shouldHandleRequest:(NSURLRequest *)request;
- (void)stopLoading;

@end
NS_ASSUME_NONNULL_END
