#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCEqualTest : XCTestCase

@end

@implementation ObjCEqualTest

- (void)testPositiveMatches {
    expect(@1).to(equal(@1));
    expect(@1).toNot(equal(@2));
    expect(@1).notTo(equal(@2));
    expect(@"hello").to(equal(@"hello"));
    expect("hello").to(equal("hello"));
    expect(NSMakeRange(0, 10)).to(equal(NSMakeRange(0, 10)));
    expect(NSMakeRange(0, 10)).toNot(equal(NSMakeRange(0, 5)));
    expect((NSInteger)1).to(equal((NSInteger)1));
    expect((NSInteger)1).toNot(equal((NSInteger)2));
    expect((NSUInteger)1).to(equal((NSUInteger)1));
    expect((NSUInteger)1).toNot(equal((NSUInteger)2));
    expect(0).to(equal(0));
    expect(1).to(equal(1));
    expect(1).toNot(equal(2));
    expect(1.0).to(equal(1.0)); // Note: not recommended, use beCloseTo() instead
    expect(1.0).toNot(equal(2.0)); // Note: not recommended, use beCloseTo() instead
    expect((float)1.0).to(equal((float)1.0));  // Note: not recommended, use beCloseTo() instead
    expect((float)1.0).toNot(equal((float)2.0));  // Note: not recommended, use beCloseTo() instead
    expect((double)1.0).to(equal((double)1.0));  // Note: not recommended, use beCloseTo() instead
    expect((double)1.0).toNot(equal((double)2.0));  // Note: not recommended, use beCloseTo() instead
    expect((long long)1).to(equal((long long)1));
    expect((long long)1).toNot(equal((long long)2));
    expect((unsigned long long)1).to(equal((unsigned long long)1));
    expect((unsigned long long)1).toNot(equal((unsigned long long)2));
}

- (void)testNimbleCurrentlyBoxesNumbersWhichAllowsImplicitTypeConversions {
    expect(1).to(equal(1.0));
    expect((long long)1).to(equal((unsigned long long)1));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect(@1).to(equal(@2));
    });
    expectFailureMessage(@"expected to not equal <1>, got <1>", ^{
        expect(@1).toNot(equal(@1));
    });
    expectFailureMessage(@"expected to not equal <bar>, got <bar>", ^{
        expect("bar").toNot(equal("bar"));
    });
    expectFailureMessage(@"expected to equal <NSRange: {0, 5}>, got <NSRange: {0, 10}>", ^{
        expect(NSMakeRange(0, 10)).to(equal(NSMakeRange(0, 5)));
    });

    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((NSInteger)1).to(equal((NSInteger)2));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((NSUInteger)1).to(equal((NSUInteger)2));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect(1).to(equal(2));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect(1.0).to(equal(2.0));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((float)1.0).to(equal((float)2.0));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((double)1.0).to(equal((double)2.0));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((long long)1.0).to(equal((long long)2.0));
    });
    expectFailureMessage(@"expected to equal <2>, got <1>", ^{
        expect((unsigned long long)1.0).to(equal((unsigned long long)2.0));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to equal <nil>, got <nil>", ^{
        expect(NULL).to(equal(NULL));
    });
    expectNilFailureMessage(@"expected to equal <nil>, got <nil>", ^{
        expect(nil).to(equal(nil));
    });
    expectNilFailureMessage(@"expected to not equal <nil>, got <nil>", ^{
        expect(nil).toNot(equal(nil));
    });
}

@end
