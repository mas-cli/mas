#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface _QuickSelectorWrapper : NSObject
- (instancetype)initWithSelector:(SEL)selector;
@end

@interface _QuickSpecBase : XCTestCase
+ (NSArray<_QuickSelectorWrapper *> *)_qck_testMethodSelectors;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end
