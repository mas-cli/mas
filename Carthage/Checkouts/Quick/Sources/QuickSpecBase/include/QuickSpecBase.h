#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface _QuickSpecBase : XCTestCase
+ (NSArray<NSString *> *)_qck_testMethodSelectors;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end
