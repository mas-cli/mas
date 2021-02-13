#import "QuickConfiguration.h"
#import <objc/runtime.h>

#if __has_include("Quick-Swift.h")
#import "Quick-Swift.h"
#else
#import <Quick/Quick-Swift.h>
#endif

@implementation QuickConfiguration

#pragma mark - Object Lifecycle

/**
 QuickConfiguration is not meant to be instantiated; it merely provides a hook
 for users to configure how Quick behaves. Raise an exception if an instance of
 QuickConfiguration is created.
 */
- (instancetype)init {
    NSString *className = NSStringFromClass([self class]);
    NSString *selectorName = NSStringFromSelector(@selector(configure:));
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ is not meant to be instantiated; "
     @"subclass %@ and override %@ to configure Quick.",
     className, className, selectorName];
    return nil;
}

#pragma mark - NSObject Overrides

/**
 Hook into when QuickConfiguration is initialized in the runtime in order to
 call +[QuickConfiguration configure:] on each of its subclasses.
 */
+ (void)initialize {
    // Only enumerate over the subclasses of QuickConfiguration, not any of its subclasses.
    if ([self class] == [QuickConfiguration class]) {
        World *world = [World sharedWorld];
        [self configureSubclassesIfNeededWithWorld:world];
    }
}

#pragma mark - Public Interface

+ (void)configure:(Configuration *)configuration { }

@end
