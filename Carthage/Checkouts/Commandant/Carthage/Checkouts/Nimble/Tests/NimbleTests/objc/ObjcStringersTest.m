@import XCTest;
@import Nimble;

@interface ObjcStringersTest : XCTestCase

@end

@implementation ObjcStringersTest

- (void)testItCanStringifyArrays {
    NSArray *array = @[@1, @2, @3];
    NSString *result = NMBStringify(array);
    
    expect(result).to(equal(@"(1, 2, 3)"));
}

- (void)testItCanStringifyIndexSets {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSString *result = NMBStringify(indexSet);

    expect(result).to(equal(@"(1, 2, 3)"));
}

- (void)testItRoundsLongDecimals {
    NSNumber *num = @291.123782163;
    NSString *result = NMBStringify(num);
    
    expect(result).to(equal(@"291.1238"));
}

@end
