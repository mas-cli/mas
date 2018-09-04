#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeginWithTest : XCTestCase

@end

@implementation ObjCBeginWithTest

- (void)testPositiveMatches {
    expect(@"hello world!").to(beginWith(@"hello"));
    expect(@"hello world!").toNot(beginWith(@"world"));

    NSArray *array = @[@1, @2];
    expect(array).to(beginWith(@1));
    expect(array).toNot(beginWith(@2));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to begin with <bar>, got <foo>", ^{
        expect(@"foo").to(beginWith(@"bar"));
    });
    expectFailureMessage(@"expected to not begin with <foo>, got <foo>", ^{
        expect(@"foo").toNot(beginWith(@"foo"));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to begin with <1>, got <nil>", ^{
        expect(nil).to(beginWith(@1));
    });
    expectNilFailureMessage(@"expected to not begin with <1>, got <nil>", ^{
        expect(nil).toNot(beginWith(@1));
    });
}

@end
