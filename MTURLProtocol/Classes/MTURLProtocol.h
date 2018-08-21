//
//  MTURLProtocol.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

@import Foundation;
@protocol MTRequestHandler;

NS_ASSUME_NONNULL_BEGIN
@interface MTURLProtocol : NSURLProtocol

@property (class, nonatomic, strong, nullable) NSArray<id<MTRequestHandler>> *requestHandlers;

@end
NS_ASSUME_NONNULL_END
