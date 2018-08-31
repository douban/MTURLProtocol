//
//  MTTestResponseHandler.h
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/31.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

@import Foundation;
@import MTURLProtocol;

@interface MTTestResponseHandler : NSObject <MTResponseHandler>

@property (nonatomic, weak) id<NSURLProtocolClient> client;
@property (nonatomic, weak) NSURLSessionTask *dataTask;
@property (nonatomic, weak) MTURLProtocol *protocol;

@end
