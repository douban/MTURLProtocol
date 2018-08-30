//
//  MTURLProtocol.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

@import Foundation;
@protocol MTRequestHandler, MTResponseHandler, MTTaskHandler;

NS_ASSUME_NONNULL_BEGIN

/**
 Every single MTURLProtocol instance uses class properties of `requestHandlers`, `responseHandlers` and `taskHandlers`
 to check if it needs genertate corresponding instances of Class<MTXXXHandler> when `-initWithRequest:cachedResponse:client:`
 or `-initWithTask:cachedResponse:client:` method is called.
 */
__attribute__((objc_subclassing_restricted))
@interface MTURLProtocol : NSURLProtocol

/**
 Ordered array, used to decorate request.
 MTURLProtocol instance uses this property to generate corresponding instances conform to MTRequestHandler protocol.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTRequestHandler>> *requestHandlers;

/**
 Used to decorate response.
 MTURLProtocol instance uses this property to generate corresponding instances conform to MTResponseHandler protocol.

 - Note: Only one MTReponseHandler protocol instance will be chosen regarding to original request and final request.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTResponseHandler>> *responseHandlers;

/**
 Used to decorate NSURLSessionTask instance in MTURLProtocol instance.
 MTURLProtocol instance uses this property to generate corresponding instances conform to MTTaskHandler protocol.

 - Note: Only one MTTaskHandker protocol instance will be chosen regarding to task.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTTaskHandler>> *taskHandlers;

/**
 Add classes conforming to MTRequestHandler protocol to MTURLProtocol.requestHandlers
 */
+ (void)addRequestHandler:(Class<MTRequestHandler>)handler;
+ (void)removeRequestHandler:(Class<MTResponseHandler>)handler;

/**
 Add classes conforming to MTResponseHandler protocol to MTURLProtocol.responseHandlers
 */
+ (void)addResponseHandler:(Class<MTResponseHandler>)handler;
+ (void)removeResponseHandler:(Class<MTResponseHandler>)handler;

/**
 Add classes conforming to MTTaskHandler protocol to MTURLProtocol.taskHandlers
 */
+ (void)addTaskHandler:(Class<MTTaskHandler>)handler;
+ (void)removeTaskHandler:(Class<MTTaskHandler>)handler;

@end
NS_ASSUME_NONNULL_END
