# MTURLProtocol

[![CI Status](https://img.shields.io/travis/duyu1010@gmail.com/MTURLProtocol.svg?style=flat)](https://travis-ci.org/duyu1010@gmail.com/MTURLProtocol)
[![Version](https://img.shields.io/cocoapods/v/MTURLProtocol.svg?style=flat)](https://cocoapods.org/pods/MTURLProtocol)
[![License](https://img.shields.io/cocoapods/l/MTURLProtocol.svg?style=flat)](https://cocoapods.org/pods/MTURLProtocol)
[![Platform](https://img.shields.io/cocoapods/p/MTURLProtocol.svg?style=flat)](https://cocoapods.org/pods/MTURLProtocol)

## Introduction
MTURLProtocol is a subclass of NSURLProtocl and itself is **subclass restricted**. It is used to avoid implementing multiple NSURLProtocol subclass in one application because multiple NSURLProtocol subclass will make it difficult to track and debug network traffic. In addition, mutiple NSURLProtocol will affect network efficiency.

If you have implemented multiple NSURLProtocol subclass and find it inconvenient to maintain those code, it's time to consider migrating to use MTURLProtocol to implement the same function.

## Structure
<img width="571" alt="ecc48ed2-a92c-11e8-9084-9edb982ab8c6" src="https://user-images.githubusercontent.com/4435768/44769961-f8a8f080-ab98-11e8-82eb-35ef2a1a5209.png">


### Handle Request
A request will be handled by your (mutiple) MTRequestHandler instance(s) in order of adding time. Before sending decorated request, you have chance to choose one of the MTTaskHandler instace to decorate dataTask used in MTURLProtocl instance.

### Handle Response
MTURLProtocol instance will choose **only one** responseHandler to handle the response regarding the `original request`: the request before decorated and the `final request`: the request before sent.

Previously, you may have multiple NSURLProtocol instance to handle different response. If more than 2 NSURLProtocol instances was handling one request, you need merge the logic into one MTResponseHandler subclass when migrating.

## Example
### 1. Subclass MTRequestHander, MTResponseHandler, MTTaskHandler if needed.
```
// DNSRequestHandler.h

@import MTURLProtocol;

@interface DNSRequestHandler : MTRequestHandler

@property (nonatomic, assign) BOOL ignoreBrowserRequest;  // default is YES.

@end

```

```
// DNSRequestHandler.m

#import "DNSRequestHandler.h"

@implementation FRDDNSRequestHandler

- (instancetype)init
{
  if (self = [super init]) {
    _ignoreBrowserRequest = YES;
  }
  return self;
}

- (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  if (_ignoreBrowserRequest && [request.allHTTPHeaderFields[@"User-Agent"] hasPrefix:@"Mozilla"]) {
    return NO;
  }

  return [request shouldBeHandled];
}

- (BOOL)canHandleRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
  return [self canInitWithRequest:request];
}

- (NSURLRequest *)decoratedRequestOfRequest:(NSURLRequest *)request originalRequest:(NSURLRequest *)originalRequest
{
	// configure header and parameters
}

- (BOOL)shouldBeHandler
{
	// decide whether to handle the request
}

```

### 2. Set handlers and register MTURLProtocol
```
  // Set handlers
  [MTURLProtocol addRequestHandler:[AccountLocalRequestHandler new]];
  [MTURLProtocol addRequestHandler:];
  [MTURLProtocol addRequestHandler:[POSTRequestHandler new]];
  
  or 
  
  MTURLProtocol.requestHandlers = @[[AccountLocalRequestHandler new], [OAuthRequestHandler new]];
  
  // Register MTURLProtocol
  [sessionConfiguration mt_registerProtocolClass:MTURLProtocol.class];
  [NSURLProtocol registerClass:MTURLProtocol.class];
```

## Installation

MTURLProtocol is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MTURLProtocol'
```

## Projects and apps using MTURLProtocol 
- [rexxar-iOS](https://github.com/douban/rexxar-ios/tree/dev/Rexxar/Classes/Core)
- [豆瓣App](https://www.douban.com/doubanapp/frodo?channel=top-nav&referer=https%3A%2F%2Fwww.douban.com%2F&wechat=0&os=Mac+OS+X)

## Author

duyu1010@gmail.com


## License

MTURLProtocol is available under the MIT license. See the LICENSE file for more info.
