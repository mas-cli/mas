#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeIdenticalToTest : XCTestCase

@end

@implementation ObjCBeIdenticalToTest

- (void)testPositiveMatches {
    NSNull *obj = [NSNull null];
    expect(obj).to(beIdenticalTo([NSNull null]));
    expect(@2).toNot(beIdenticalTo(@3));
}

- (void)testNegativeMatches {
    NSNull *obj = [NSNull null];
    expectFailureMessage(([NSString stringWithFormat:@"expected to be identical to <%p>, got <%p>", obj, @2]), ^{
        expect(@2).to(beIdenticalTo(obj));
    });
    expectFailureMessage(([NSString stringWithFormat:@"expected to not be identical to <%p>, got <%p>", obj, obj]), ^{
        expect(obj).toNot(beIdenticalTo(obj));
    });
}

- (void)testNilMatches {
    NSNull *obj = [NSNull null];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    expectNilFailureMessage(@"expected to be identical to nil, got nil", ^{
        expect(nil).to(beIdenticalTo(nil));
    });
#pragma clang diagnostic pop
    expectNilFailureMessage(([NSString stringWithFormat:@"expected to not be identical to <%p>, got nil", obj]), ^{
        expect(nil).toNot(beIdenticalTo(obj));
    });
}

- (void)testAliasPositiveMatches {
    NSNull *obj = [NSNull null];
    expect(obj).to(be([NSNull null]));
    expect(@2).toNot(be(@3));
}

- (void)testAliasNegativeMatches {
    NSNull *obj = [NSNull null];
    expectFailureMessage(([NSString stringWithFormat:@"expected to be identical to <%p>, got <%p>", obj, @2]), ^{
        expect(@2).to(be(obj));
    });
    expectFailureMessage(([NSString stringWithFormat:@"expected to not be identical to <%p>, got <%p>", obj, obj]), ^{
        expect(obj).toNot(be(obj));
    });
}

- (void)testAliasNilMatches {
    NSNull *obj = [NSNull null];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    expectNilFailureMessage(@"expected to be identical to nil, got nil", ^{
        expect(nil).to(be(nil));
    });
#pragma clang diagnostic pop
    expectNilFailureMessage(([NSString stringWithFormat:@"expected to not be identical to <%p>, got nil", obj]), ^{
        expect(nil).toNot(be(obj));
    });
}

@end
