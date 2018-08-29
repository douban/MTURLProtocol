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
 to check if it needs genertate corresponding array of instances of Class<MTXXXHandler> when `-initWithRequest:cachedResponse:client:`
 or `-initWithTask:cachedResponse:client:` method is called.
 */
__attribute__((objc_subclassing_restricted))
@interface MTURLProtocol : NSURLProtocol

/**
 Ordered array, responsible for decorating request.

 - Note: Each requestHandler will be called if it can handler corresponding request.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTRequestHandler>> *requestHandlers;

/**
 Responsible for dealing with response.

 - Note: Only one reponseHandler will be chose regarding to original request and final request.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTResponseHandler>> *responseHandlers;

/**
 Responseble for decorating NSURLSessionTask instance used by MTURLProtocol instance to send request.

 - Note: Only one taskHandler will be called regarding to task.
 */
@property (class, nonatomic, copy, nullable) NSArray<Class<MTTaskHandler>> *taskHandlers;

/**
 add requestHandler to MTURLProtocol.requestHandlers

 - Note: Only support adding one instance of the specific MTRequestHandler protocol.
 */
+ (void)addRequestHandler:(Class<MTRequestHandler>)handler;
+ (void)removeRequestHandler:(Class<MTResponseHandler>)handler;

/**
 add responseHandler to MTURLProtocol.responseHandlers

 - Note: Only support adding one instance of the specific MTResponseHandler protocol.
 */
+ (void)addResponseHandler:(Class<MTResponseHandler>)handler;
+ (void)removeResponseHandler:(Class<MTResponseHandler>)handler;

/**
 add taskHandler to MTURLProtocol.taskHandlers

 - Note: Only support adding one instance of the specific MTTaskHandler protocol.
 */
+ (void)addTaskHandler:(Class<MTTaskHandler>)handler;
+ (void)removeTaskHandler:(Class<MTTaskHandler>)handler;

@end
NS_ASSUME_NONNULL_END
