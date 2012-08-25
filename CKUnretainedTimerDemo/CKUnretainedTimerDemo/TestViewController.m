/* ----------------------------------------------------------------------
 TestViewController.m
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

#import "TestViewController.h"
#import "CKUnretainedTimer.h"

#define kUseCKUndefinedTimer 1

/* ----------------------------------------------------------------------
 @interface TestViewController ()
 ---------------------------------------------------------------------- */

@interface TestViewController ()

@property (nonatomic, strong, readwrite) NSTimer *_NSTimer;
@property (nonatomic, strong, readwrite) CKUnretainedTimer *_CKUnretainedTimer;

@end

/* ----------------------------------------------------------------------
 @implementation TestViewController
 ---------------------------------------------------------------------- */

@implementation TestViewController
@synthesize _CKUnretainedTimer = __CKUnretainedTimer;
@synthesize _NSTimer = __NSTimer;

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];

    if (kUseCKUndefinedTimer) {
        self._CKUnretainedTimer = [CKUnretainedTimer timerWithTimeInterval:1.0f
                                                                    target:self
                                                                  selector:@selector(_tick:)
                                                                  userInfo:@"CKUnretainedTimer"
                                                                   repeats:YES
                                                        startAutomatically:YES];
    }
    else {
        self._NSTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(_tick:)
                                                       userInfo:@"NSTimer"
                                                        repeats:YES];
    }
}

#pragma mark Timer

- (void)_tick:(id)timer {
    if (kUseCKUndefinedTimer)
        NSLog(@"<%@> ticked!", ((CKUnretainedTimer *)timer).userInfo);
    else
        NSLog(@"<%@> ticked!", ((NSTimer *)timer).userInfo);
}

#pragma mark Dealloc

- (void)dealloc {
    
    // You'll see that this won't be called if you use the Apple's NSTimer.
    NSLog(@"Dealloc was called.");
}

@end
