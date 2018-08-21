//
//  MTRequestHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>

@protocol MTRequestHandler <NSObject>

- (BOOL)canInitWithRequest:(NSURLRequest *)request;
- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request;

@end
