#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeKindOfTest : XCTestCase

@end

@implementation ObjCBeKindOfTest

- (void)testPositiveMatches {
    NSMutableArray *array = [NSMutableArray array];
    expect(array).to(beAKindOf([NSArray class]));
    expect(@1).toNot(beAKindOf([NSNull class]));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be a kind of NSNull, got <__NSCFNumber instance>", ^{
        expect(@1).to(beAKindOf([NSNull class]));
    });
    expectFailureMessage(@"expected to not be a kind of NSNull, got <NSNull instance>", ^{
        expect([NSNull null]).toNot(beAKindOf([NSNull class]));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to be a kind of NSNull, got <nil>", ^{
        expect(nil).to(beAKindOf([NSNull class]));
    });
    expectNilFailureMessage(@"expected to not be a kind of NSNull, got <nil>", ^{
        expect(nil).toNot(beAKindOf([NSNull class]));
    });
}

@end
