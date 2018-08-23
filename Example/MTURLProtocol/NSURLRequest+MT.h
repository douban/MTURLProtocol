//
//  NSURLRequest+MT.h
//  MTURLProtocol_Example
//
//  Created by bigyelow on 2018/8/23.
//  Copyright © 2018 duyu1010@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (MT)

- (BOOL)mt_isDNSRequest;
- (BOOL)mt_isRXRRemoteRequest;
- (BOOL)mt_isRXRAccountLocalRequest;

@end
