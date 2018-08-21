//
//  MTURLSessionDataTaskInfo.m
//  DOUFoundation
//
//  Created by bigyelow on 2018/5/19.
//

#import "MTURLSessionDataTaskInfo.h"

@interface MTURLSessionDataTaskInfo ()

@property (nonatomic, assign) NSUInteger taskID;
@property (nonatomic, weak) id<NSURLSessionDataDelegate> delegate;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, copy) NSArray *modes;

@end

@implementation MTURLSessionDataTaskInfo

- (instancetype)initWithTaskID:(NSUInteger)taskID delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes
{
  self = [super init];
  if (self != nil) {
    _taskID = taskID;
    _delegate = delegate;
    _thread = [NSThread currentThread];
    _modes = [modes copy];
  }
  return self;
}

- (void)performBlock:(dispatch_block_t)block
{
  NSAssert(_delegate != nil, nil);
  NSAssert(_thread != nil, nil);
  
  if (_delegate != nil && _thread != nil) {
    [self performSelector:@selector(_frd_performBlockOnTargetThread:)
                 onThread:_thread
               withObject:[block copy]
            waitUntilDone:NO
                    modes:_modes];
  }
}

- (void)invalidate
{
  _delegate = nil;
  _thread = nil;
}

- (void)_frd_performBlockOnTargetThread:(dispatch_block_t)block
{
  NSAssert([NSThread currentThread] == _thread, nil);
  block();
}

@end
