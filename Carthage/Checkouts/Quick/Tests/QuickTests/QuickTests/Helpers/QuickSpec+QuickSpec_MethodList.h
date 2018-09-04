#import <Quick/Quick.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuickSpec (QuickSpec_MethodList)

/**
 *  This method will instantiate an instance of the class on which it is called,
 *  returning a list of selector names for it.
 *
 *  @return a set of NSStrings representing the list of selectors it contains
 */
+ (NSSet<NSString *> *)allSelectors;

@end

NS_ASSUME_NONNULL_END
