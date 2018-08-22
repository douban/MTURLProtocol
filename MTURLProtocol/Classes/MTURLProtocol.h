//
//  MTURLProtocol.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

@import Foundation;
@class MTRequestHandler, MTResponseHandler;

NS_ASSUME_NONNULL_BEGIN
@interface MTURLProtocol : NSURLProtocol

@property (class, nonatomic, copy, nullable) NSArray<MTRequestHandler *> *requestHandlers;
@property (class, nonatomic, copy, nullable) NSArray<MTResponseHandler *> *responseHandlers;

+ (void)registerWithSessionConfiguration:(NSURLSessionConfiguration *)config;
+ (void)unregisterWithSessionConfiguration:(NSURLSessionConfiguration *)config;

@end
NS_ASSUME_NONNULL_END
