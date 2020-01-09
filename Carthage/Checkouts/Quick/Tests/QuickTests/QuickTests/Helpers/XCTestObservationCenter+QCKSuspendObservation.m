@import XCTest;
#import <objc/runtime.h>

@interface XCTestObservationCenter (Redeclaration)
- (id)observers;
- (void)removeTestObserver:(id<XCTestObservation>)testObserver;
@end

@implementation XCTestObservationCenter (QCKSuspendObservation)

/// This allows us to only suspend observation for observers by provided by Apple
/// as a part of the XCTest framework. In particular it is important that we not
/// suspend the observer added by Nimble, otherwise it is unable to properly
/// report assertion failures.
static BOOL (^isFromApple)(id) = ^BOOL(id observer){
    return [[NSBundle bundleForClass:[observer class]].bundleIdentifier containsString:@"com.apple.dt.XCTest"];
};

- (void)qck_suspendObservationForBlock:(void (^)(void))block {
    id originalObservers = [[self observers] copy];
    NSMutableArray *suspendedObservers = [NSMutableArray new];

    for (id observer in originalObservers) {
        if (isFromApple(observer)) {
            [suspendedObservers addObject:observer];

            if ([self respondsToSelector:@selector(removeTestObserver:)]) {
                [self removeTestObserver:observer];
            }
            else if ([[self observers] respondsToSelector:@selector(removeObject:)]) {
                [[self observers] removeObject:observer];
            }
            else {
                NSAssert(NO, @"unexpected type: unable to remove observers: %@", originalObservers);
            }
        }
    }

    @try {
        block();
    }
    @finally {
        for (id observer in suspendedObservers) {
            if ([[self observers] respondsToSelector:@selector(addObject:)]) {
                [[self observers] addObject:observer];
            }
            else if ([self respondsToSelector:@selector(addTestObserver:)]) {
                [self addTestObserver:observer];
            }
        }
    }
}

@end
