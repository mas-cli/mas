#import "QuickSpec+QuickSpec_MethodList.h"
#import <objc/runtime.h>


@implementation QuickSpec (QuickSpec_MethodList)

+ (NSSet<NSString*> *)allSelectors {
    QuickSpec *specInstance = [[[self class] alloc] init];
    NSMutableSet<NSString *> *allSelectors = [NSMutableSet set];
    
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(object_getClass(specInstance), &methodCount);

    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methodList[i]);
        [allSelectors addObject:NSStringFromSelector(selector)];
    }
    
    free(methodList);
    return [allSelectors copy];
}

@end
