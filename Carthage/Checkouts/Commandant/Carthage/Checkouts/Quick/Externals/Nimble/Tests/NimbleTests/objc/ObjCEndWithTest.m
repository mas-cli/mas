#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCEndWithTest : XCTestCase

@end

@implementation ObjCEndWithTest

- (void)testPositiveMatches {
    NSArray *array = @[@1, @2];
    expect(@"hello world!").to(endWith(@"world!"));
    expect(@"hello world!").toNot(endWith(@"hello"));
    expect(array).to(endWith(@2));
    expect(array).toNot(endWith(@1));
    expect(@1).toNot(contain(@"foo"));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to end with <?>, got <hello world!>", ^{
        expect(@"hello world!").to(endWith(@"?"));
    });
    expectFailureMessage(@"expected to not end with <!>, got <hello world!>", ^{
        expect(@"hello world!").toNot(endWith(@"!"));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to end with <1>, got <nil>", ^{
        expect(nil).to(endWith(@1));
    });
    expectNilFailureMessage(@"expected to not end with <1>, got <nil>", ^{
        expect(nil).toNot(endWith(@1));
    });
}

@end
