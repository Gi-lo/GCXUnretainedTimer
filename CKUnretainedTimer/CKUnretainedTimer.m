/* ----------------------------------------------------------------------
 CKUnretainedTimer.h
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

#import "CKUnretainedTimer.h"
#include <objc/objc-runtime.h>

/* ----------------------------------------------------------------------
 @interface CKUnretainedTimer ()
 ---------------------------------------------------------------------- */

@interface CKUnretainedTimer ()

@property (nonatomic, unsafe_unretained, readwrite) dispatch_source_t _timerSource;
@property (nonatomic, unsafe_unretained, getter = isValid, readwrite) BOOL isValid;
@property (nonatomic, unsafe_unretained, readwrite) id userInfo;

- (id)_initWithTimeinterval:(NSTimeInterval)interval
                      block:(CKUnretainedTimerBlock)block
                   userInfo:(id)userInfo
                    repeats:(BOOL)repeats
         startAutomatically:(BOOL)startAutomatically;

@end

/* ----------------------------------------------------------------------
 @implementation CKUnretainedTimer
 ---------------------------------------------------------------------- */

@implementation CKUnretainedTimer
@synthesize _timerSource = __timerSource;
@synthesize isValid = _isValid;
@synthesize userInfo = _userInfo;

#pragma mark Init

+ (CKUnretainedTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                                       block:(CKUnretainedTimerBlock)block
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats
                          startAutomatically:(BOOL)startAutomatically {
    return [[CKUnretainedTimer alloc] _initWithTimeinterval:interval
                                                      block:block
                                                   userInfo:userInfo
                                                    repeats:repeats
                                         startAutomatically:startAutomatically];
}

+ (CKUnretainedTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)target
                                    selector:(SEL)selector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats
                          startAutomatically:(BOOL)startAutomatically {
    
    __weak id weakTarget = target;
    CKUnretainedTimerBlock timerBlock = ^(CKUnretainedTimer *timer){
        objc_msgSend(weakTarget, selector, timer);
    };

    return [self timerWithTimeInterval:interval
                                 block:timerBlock
                              userInfo:userInfo
                               repeats:repeats
                    startAutomatically:startAutomatically];
}

- (id)_initWithTimeinterval:(NSTimeInterval)interval
                      block:(CKUnretainedTimerBlock)block
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
            
            __weak CKUnretainedTimer *weakSelf = self;
            dispatch_source_set_event_handler(__timerSource, ^{
                block(weakSelf);

                if (!repeats)
                    dispatch_source_cancel(weakSelf._timerSource);
            });
            
            _isValid = YES;
            _userInfo = userInfo;

            if (startAutomatically)
                [self fire];
        }
    }
    
    return self;
}

#pragma mark Start/Stop timer

- (void)fire {
    NSParameterAssert(self.isValid);
    dispatch_resume(self._timerSource);
}

- (void)invalidate {
    dispatch_source_cancel(__timerSource);
    self.isValid = NO;
}

#pragma mark Dealloc

- (void)dealloc {
    dispatch_source_cancel(__timerSource);
    dispatch_release(__timerSource);
}

@end