#if __has_include("Quick-Swift.h")
#import "Quick-Swift.h"
#else
#import <Quick/Quick-Swift.h>
#endif

@class ExampleGroup;
@class ExampleMetadata;

SWIFT_CLASS("_TtC5Quick5World")
@interface World

@property (nonatomic) ExampleGroup * __nullable currentExampleGroup;
@property (nonatomic) ExampleMetadata * __nullable currentExampleMetadata;
@property (nonatomic) BOOL isRunningAdditionalSuites;
+ (World * __nonnull)sharedWorld;
- (void)configure:(void (^ __nonnull)(Configuration * __nonnull))closure;
- (void)finalizeConfiguration;
- (ExampleGroup * __nonnull)rootExampleGroupForSpecClass:(Class __nonnull)cls;
- (NSArray * __nonnull)examplesForSpecClass:(Class __nonnull)specClass;
- (void)performWithCurrentExampleGroup:(ExampleGroup * __nonnull)group closure:(void (^ __nonnull)(void))closure;
@end
