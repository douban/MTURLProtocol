//
//  MTURLProtocol.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

@import Foundation;
@class MTRequestHandler, MTResponseHandler, MTTaskHandler;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTURLProtocol : NSURLProtocol

/**
 Ordered array, responsible for decorating request.

 - Note: Each requestHandler will be called if can handler corresponding request.
 */
@property (class, nonatomic, copy, nullable) NSArray<MTRequestHandler *> *requestHandlers;

/**
 Responsible for dealing with response.

 - Note: Only one reponseHandler will be called regarding to originalRequest and decorated request.
 */
@property (class, nonatomic, copy, nullable) NSArray<MTResponseHandler *> *responseHandlers;

/**
 Responseble for decorating NSURLSessionTask instance used by MTURLProtocol instance to send request.

 - Note: Only one ** taskHandler will be called regarding to task.
 */
@property (class, nonatomic, copy, nullable) NSArray<MTTaskHandler *> *taskHandlers;

/**
 add requestHandler to MTURLProtocol.requestHandlers

 - Note: Only support adding one instance of the specific MTRequestHandler subclass.
 */
+ (void)addRequestHandler:(nullable MTRequestHandler *)handler;
+ (void)removeRequestHandler:(nullable MTRequestHandler *)handler;
+ (void)removeRequestHandlerByClass:(Class)class;

/**
 add responseHandler to MTURLProtocol.responseHandlers

 - Note: Only support adding one instance of the specific MTResponseHandler subclass.
 */
+ (void)addResponseHandler:(nullable MTResponseHandler *)handler;
+ (void)removeResponseHandler:(nullable MTResponseHandler *)handler;
+ (void)removeResponseHandlerByClass:(Class)class;

/**
 add taskHandler to MTURLProtocol.taskHandlers

 - Note: Only support adding one instance of the specific MTTaskHandler subclass.
 */
+ (void)addTaskHandler:(nullable MTTaskHandler *)handler;
+ (void)removeTaskHandler:(nullable MTTaskHandler *)handler;
+ (void)removeTaskHandlerByClass:(Class)class;

@end
NS_ASSUME_NONNULL_END
