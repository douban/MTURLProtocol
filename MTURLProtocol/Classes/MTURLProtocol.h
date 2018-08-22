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

+ (void)registerWithSessionConfiguration:(NSURLSessionConfiguration *)config;
+ (void)unregisterWithSessionConfiguration:(NSURLSessionConfiguration *)config;

+ (void)setResponseHandler:(MTResponseHandler *)responseHandler
  forRequestHandlerClasses:(NSArray<Class> *)requestHandlerClasses;

@end
NS_ASSUME_NONNULL_END
