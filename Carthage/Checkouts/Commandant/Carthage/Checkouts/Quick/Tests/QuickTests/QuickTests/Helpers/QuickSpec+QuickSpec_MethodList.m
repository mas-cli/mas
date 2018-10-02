#import "QuickSpec+QuickSpec_MethodList.h"
#import <objc/runtime.h>


@implementation QuickSpec (QuickSpec_MethodList)

/**
 *  This method will instantiate an instance of the class on which it is called,
 *  returning a list of selector names for it.
 *
 *  @warning Only intended to be used in test assertions!
 *
 *  @return a set of NSStrings representing the list of selectors it contains
 */
+ (NSSet<NSString*> *)allSelectors {
    QuickSpec *specInstance = [[[self class] alloc] init];
    NSMutableSet<NSString*> *allSelectors = [NSMutableSet set];
    
    unsigned int methodCount = 0;
    Method *mlist = class_copyMethodList(object_getClass(specInstance), &methodCount);

    for(unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(mlist[i]);
        [allSelectors addObject:NSStringFromSelector(selector)];
    }
    
    free(mlist);
    return [allSelectors copy];
}

@end
