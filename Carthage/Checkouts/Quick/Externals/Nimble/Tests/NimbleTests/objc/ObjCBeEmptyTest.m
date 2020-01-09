#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeEmptyTest : XCTestCase
@end

@implementation ObjCBeEmptyTest

- (void)testPositiveMatches {
    expect(@[]).to(beEmpty());
    expect(@"").to(beEmpty());
    expect(@{}).to(beEmpty());
    expect([NSSet set]).to(beEmpty());
    expect([NSIndexSet indexSet]).to(beEmpty());
    expect([NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory]).to(beEmpty());

    expect(@[@1, @2]).toNot(beEmpty());
    expect(@"a").toNot(beEmpty());
    expect(@{@"key": @"value"}).toNot(beEmpty());
    expect([NSSet setWithObject:@1]).toNot(beEmpty());
    expect([NSIndexSet indexSetWithIndex:1]).toNot(beEmpty());

    NSHashTable *table = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    [table addObject:@1];
    expect(table).toNot(beEmpty());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be empty, got <foo>", ^{
        expect(@"foo").to(beEmpty());
    });
    expectFailureMessage(@"expected to be empty, got <(1)>", ^{
        expect(@[@1]).to(beEmpty());
    });
    expectFailureMessage(@"expected to be empty, got <{key = value;}>", ^{
        expect(@{@"key": @"value"}).to(beEmpty());
    });
    expectFailureMessage(@"expected to be empty, got <{(1)}>", ^{
        expect([NSSet setWithObject:@1]).to(beEmpty());
    });
    expectFailureMessage(@"expected to be empty, got <(1)>", ^{
        expect([NSIndexSet indexSetWithIndex:1]).to(beEmpty());
    });
    NSHashTable *table = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    [table addObject:@1];
    NSString *tableString = [[table description] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    expectFailureMessage(([NSString stringWithFormat:@"expected to be empty, got <%@>", tableString]), ^{
        expect(table).to(beEmpty());
    });

    expectFailureMessage(@"expected to not be empty, got <>", ^{
        expect(@"").toNot(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty, got <()>", ^{
        expect(@[]).toNot(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty, got <{}>", ^{
        expect(@{}).toNot(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty, got <{()}>", ^{
        expect([NSSet set]).toNot(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty, got <()>", ^{
        expect([NSIndexSet indexSet]).toNot(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty, got <NSHashTable {}>", ^{
        expect([NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory]).toNot(beEmpty());
    });
}

- (void)testItDoesNotMatchNil {
    expectNilFailureMessage(@"expected to be empty, got <nil>", ^{
        expect(nil).to(beEmpty());
    });
    expectNilFailureMessage(@"expected to not be empty, got <nil>", ^{
        expect(nil).toNot(beEmpty());
    });
}

- (void)testItReportsTypesItMatchesAgainst {
    expectFailureMessage(@"expected to be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings), got __NSCFNumber type", ^{
        expect(@1).to(beEmpty());
    });
    expectFailureMessage(@"expected to not be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings), got __NSCFNumber type", ^{
        expect(@1).toNot(beEmpty());
    });
}

@end
