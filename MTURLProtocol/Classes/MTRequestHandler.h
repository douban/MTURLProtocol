//
//  MTRequestHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Subclass this class if needed.
 Used to decorate request. MTRequestHandler instance will be called in order of adding time.
 */
@interface MTRequestHandler : NSObject

/**
 Used in NSURLProtocol +canInitWithRequest: method.
 */
- (BOOL)canInitWithRequest:(NSURLRequest *)request;

/**
 Used in decorating process.

 @param request         The last request decorated by last requestHandler.
 @param originalRequest The request before any decorating.
 */
- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest;

/**
 Used in decorating process.

 @param request         The last request decorated by last requestHandler.
 @param originalRequest The request before any decorating.
 @return                Decorated request.
 */
- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest;

@end
NS_ASSUME_NONNULL_END
