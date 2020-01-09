#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCAllPassTest : XCTestCase

@end

@implementation ObjCAllPassTest

- (void)testPositiveMatches {
    expect(@[@1, @2, @3,@4]).to(allPass(beLessThan(@5)));
    expect(@[@1, @2, @3,@4]).toNot(allPass(beGreaterThan(@5)));
    
    expect([NSSet setWithArray:@[@1, @2, @3,@4]]).to(allPass(beLessThan(@5)));
    expect([NSSet setWithArray:@[@1, @2, @3,@4]]).toNot(allPass(beGreaterThan(@5)));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to all be less than <3>, but failed first at element"
                         " <3> in <[1, 2, 3, 4]>", ^{
                             expect(@[@1, @2, @3, @4]).to(allPass(beLessThan(@3)));
                         });
    expectFailureMessage(@"expected to not all be less than <5>", ^{
        expect(@[@1, @2, @3, @4]).toNot(allPass(beLessThan(@5)));
    });
    expectFailureMessage(@"expected to not all be less than <5>", ^{
        expect([NSSet setWithArray:@[@1, @2, @3, @4]]).toNot(allPass(beLessThan(@5)));
    });
    expectFailureMessage(@"allPass can only be used with types which implement NSFastEnumeration "
                         "(NSArray, NSSet, ...), and whose elements subclass NSObject, got <3>", ^{
                             expect(@3).to(allPass(beLessThan(@5)));
                         });
    expectFailureMessage(@"allPass can only be used with types which implement NSFastEnumeration "
                         "(NSArray, NSSet, ...), and whose elements subclass NSObject, got <3>", ^{
                             expect(@3).toNot(allPass(beLessThan(@5)));
                         });
}
@end
