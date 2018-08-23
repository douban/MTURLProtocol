//
//  NSHTTPURLResponse+Utils.h
//  AFNetworking
//
//  Created by bigyelow on 2018/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSHTTPURLResponse (Utils)

+ (nullable instancetype)mt_responseWithURL:(NSURL *)url
                                 statusCode:(NSInteger)statusCode
                               headerFields:(nullable NSDictionary<NSString *, NSString *> *)headerFields
                            noAccessControl:(BOOL)noAccessControl;

@end
NS_ASSUME_NONNULL_END
