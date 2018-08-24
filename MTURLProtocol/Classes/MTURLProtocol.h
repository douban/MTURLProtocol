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

@property (class, nonatomic, copy, nullable) NSArray<MTRequestHandler *> *requestHandlers;
@property (class, nonatomic, copy, nullable) NSArray<MTResponseHandler *> *responseHandlers;
@property (class, nonatomic, copy, nullable) NSArray<MTTaskHandler *> *taskHandlers;

@end
NS_ASSUME_NONNULL_END
