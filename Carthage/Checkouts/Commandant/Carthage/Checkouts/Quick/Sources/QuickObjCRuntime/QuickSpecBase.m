#import "QuickSpecBase.h"

#pragma mark - _QuickSpecBase

@implementation _QuickSpecBase

- (instancetype)init {
    self = [super initWithInvocation: nil];
    return self;
}

/**
 Invocations for each test method in the test case. QuickSpec overrides this method to define a
 new method for each example defined in +[QuickSpec spec].

 @return An array of invocations that execute the newly defined example methods.
 */
+ (NSArray<NSInvocation *> *)testInvocations {
    NSArray<NSString *> *selectors = [self _qck_testMethodSelectors];
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray arrayWithCapacity:selectors.count];

    for (NSString *selectorString in selectors) {
        SEL selector = NSSelectorFromString(selectorString);
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = selector;

        [invocations addObject:invocation];
    }

    return invocations;
}

+ (NSArray<NSString *> *)_qck_testMethodSelectors {
    return @[];
}

@end
