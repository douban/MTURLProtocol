//
//  MTRequestHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MTRequestHandler : NSObject

- (BOOL)canInitWithRequest:(NSURLRequest *)request;
- (nullable NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request;

@end
NS_ASSUME_NONNULL_END
