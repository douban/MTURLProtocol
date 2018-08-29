//
//  MTResponseHandler.h
//  MTURLProtocol
//
//  Created by bigyelow on 2018/8/21.
//

#import <Foundation/Foundation.h>
@class MTURLProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
 Used in MTURLProtocl instance's NSURLSessionTaskDelegate and NSURLSessionDataDelegate methods. Those delegate methods
 will be forward to valid responseHandler set to MTURLProtocol.
 */
@protocol MTResponseHandler <NSObject, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak) id<NSURLProtocolClient> client; // MTURLProtocol instance.client
@property (nonatomic, weak) NSURLSessionTask *dataTask; //  MTURLProtocol instance.dataTask
@property (nonatomic, weak) MTURLProtocol *protocol;  // MTURLProtocol

/**
 Used in MTURLProtocl instance's choosing responseHandler process.

 @param request           The request before sent
 @param originalRequest   The request before decorated
 */
- (BOOL)shouldHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest;

@optional
/**
 MTURLProcotl instance will call this method in its -stopLoading method. Do anything you need to finish loading process
 regarding to your custom response dealing logic.
 */
- (void)stopLoading;

@end
NS_ASSUME_NONNULL_END
