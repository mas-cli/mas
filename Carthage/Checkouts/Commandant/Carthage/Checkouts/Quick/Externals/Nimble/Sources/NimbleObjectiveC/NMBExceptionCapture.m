#import "NMBExceptionCapture.h"

@interface NMBExceptionCapture ()
@property (nonatomic, copy) void(^ _Nullable handler)(NSException * _Nullable);
@property (nonatomic, copy) void(^ _Nullable finally)(void);
@end

@implementation NMBExceptionCapture

- (nonnull instancetype)initWithHandler:(void(^ _Nullable)(NSException * _Nonnull))handler finally:(void(^ _Nullable)(void))finally {
    self = [super init];
    if (self) {
        self.handler = handler;
        self.finally = finally;
    }
    return self;
}

- (void)tryBlock:(void(^ _Nonnull)(void))unsafeBlock {
    @try {
        unsafeBlock();
    }
    @catch (NSException *exception) {
        if (self.handler) {
            self.handler(exception);
        }
    }
    @finally {
        if (self.finally) {
            self.finally();
        }
    }
}

@end
