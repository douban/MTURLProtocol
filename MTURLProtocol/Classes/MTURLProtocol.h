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

@property (class, nonatomic, strong, nullable) NSArray<MTRequestHandler *> *requestHandlers;
@property (class, nonatomic, strong, nullable) MTResponseHandler *responseHandler;

+ (void)registerWithSessionConfiguration:(NSURLSessionConfiguration *)config;
+ (void)unregisterWithSessionConfiguration:(NSURLSessionConfiguration *)config;

@end
NS_ASSUME_NONNULL_END
