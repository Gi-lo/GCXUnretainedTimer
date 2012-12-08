/* ----------------------------------------------------------------------
 
 GCXUnretainedTimer.m
 
 Copyright 2012 Giulio Petek. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 ---------------------------------------------------------------------- */

#import "GCXUnretainedTimer.h"
#include <objc/objc-runtime.h>

/* ----------------------------------------------------------------------
 @interface GCXUnretainedTimer ()
 ---------------------------------------------------------------------- */

@interface GCXUnretainedTimer ()

@property (nonatomic, unsafe_unretained, readwrite) dispatch_source_t _timerSource;
@property (nonatomic, unsafe_unretained, getter = isValid, readwrite) BOOL isValid;
@property (nonatomic, unsafe_unretained, readwrite) id userInfo;

- (GCXUnretainedTimer *)_initWithTimeinterval:(NSTimeInterval)interval
                                        block:(GCXUnretainedTimerBlock)block
                                     userInfo:(id)userInfo
                                      repeats:(BOOL)repeats
                           startAutomatically:(BOOL)startAutomatically;

@end

/* ----------------------------------------------------------------------
 @implementation GCXUnretainedTimer
 ---------------------------------------------------------------------- */

@implementation GCXUnretainedTimer

#pragma mark Init

+ (GCXUnretainedTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                                        block:(GCXUnretainedTimerBlock)block
                                      repeats:(BOOL)repeats
                           startAutomatically:(BOOL)startAutomatically {
    return [[GCXUnretainedTimer alloc] _initWithTimeinterval:interval
                                                      block:block
                                                   userInfo:nil
                                                    repeats:repeats
                                         startAutomatically:startAutomatically];
}

+ (GCXUnretainedTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                                       target:(id)target
                                     selector:(SEL)selector
                                     userInfo:(id)userInfo
                                      repeats:(BOOL)repeats
                           startAutomatically:(BOOL)startAutomatically {
    
    __weak id weakTarget = target;
    GCXUnretainedTimerBlock timerBlock = ^(GCXUnretainedTimer *timer){
        __strong id strongTarget = weakTarget;

        objc_msgSend(strongTarget, selector, timer);
    };
    
    GCXUnretainedTimer *timer = [self timerWithTimeInterval:interval
                                                      block:timerBlock
                                                    repeats:repeats
                                         startAutomatically:startAutomatically];
    timer.userInfo = userInfo;
    
    return timer;
}

- (GCXUnretainedTimer *)_initWithTimeinterval:(NSTimeInterval)interval
                                        block:(GCXUnretainedTimerBlock)block
                                     userInfo:(id)userInfo
                                      repeats:(BOOL)repeats
                           startAutomatically:(BOOL)startAutomatically {
    if ((self = [super init])) {
        NSParameterAssert(block);
        
        if ((self = [super init])) {
            __timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_current_queue());
            
            uint64_t timeInterval = interval * NSEC_PER_SEC;
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, timeInterval);
            dispatch_source_set_timer(__timerSource, start, timeInterval, 0);
            
            dispatch_source_set_event_handler(__timerSource, ^{
                block(self);
                
                if (!repeats) {
                    dispatch_source_cancel(self._timerSource);
                }
            });
            
            _isValid = YES;
            _userInfo = userInfo;
            
            if (startAutomatically) {
                [self fire];
            }
        }
    }
    
    return self;
}

#pragma mark Start/Stop timer

- (void)fire {
    if (!self.isValid) {
        return;
    }
    
    dispatch_resume(self._timerSource);
}

- (void)invalidate {
    if (!self.isValid) {
        return;
    }
    
    dispatch_source_cancel(__timerSource);
    self.isValid = NO;
}

#pragma mark Dealloc

- (void)dealloc {
    dispatch_source_cancel(__timerSource);
    dispatch_release(__timerSource);
}

@end