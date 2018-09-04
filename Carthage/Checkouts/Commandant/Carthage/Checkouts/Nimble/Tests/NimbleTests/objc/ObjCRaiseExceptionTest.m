#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCRaiseExceptionTest : XCTestCase

@end

@implementation ObjCRaiseExceptionTest

- (void)testPositiveMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectAction(^{ @throw exception; }).to(raiseException());
    expectAction(^{ [exception raise]; }).to(raiseException());
    expectAction(^{ [exception raise]; }).to(raiseException().named(NSInvalidArgumentException));
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             named(NSInvalidArgumentException).
                                             reason(@"No food"));
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             named(NSInvalidArgumentException).
                                             reason(@"No food").
                                             userInfo(@{@"key": @"value"}));

    expectAction(^{ }).toNot(raiseException());
}

- (void)testPositiveMatchesWithBlocks {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             satisfyingBlock(^(NSException *exception) {
        expect(exception.name).to(equal(NSInvalidArgumentException));
    }));
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             named(NSInvalidArgumentException).
                                             satisfyingBlock(^(NSException *exception) {
        expect(exception.name).to(equal(NSInvalidArgumentException));
    }));
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             named(NSInvalidArgumentException).
                                             reason(@"No food").
                                             satisfyingBlock(^(NSException *exception) {
        expect(exception.name).to(equal(NSInvalidArgumentException));
    }));
    expectAction(^{ [exception raise]; }).to(raiseException().
                                             named(NSInvalidArgumentException).
                                             reason(@"No food").
                                             userInfo(@{@"key": @"value"}).
                                             satisfyingBlock(^(NSException *exception) {
        expect(exception.name).to(equal(NSInvalidArgumentException));
    }));
}

- (void)testNegativeMatches {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];

    expectFailureMessage(@"expected to raise any exception, got no exception", ^{
        expectAction(^{ }).to(raiseException());
    });

    expectFailureMessage(@"expected to raise exception with name <foo>, got no exception", ^{
        expectAction(^{ }).to(raiseException().
                              named(@"foo"));
    });

    expectFailureMessage(@"expected to raise exception with name <NSInvalidArgumentException> with reason <cakes>, got no exception", ^{
        expectAction(^{ }).to(raiseException().
                              named(NSInvalidArgumentException).
                              reason(@"cakes"));
    });

    expectFailureMessage(@"expected to raise exception with name <NSInvalidArgumentException> with reason <No food> with userInfo <{k = v;}>, got no exception", ^{
        expectAction(^{ }).to(raiseException().
                              named(NSInvalidArgumentException).
                              reason(@"No food").
                              userInfo(@{@"k": @"v"}));
    });

    expectFailureMessage(@"expected to not raise any exception, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }", ^{
        expectAction(^{ [exception raise]; }).toNot(raiseException());
    });
}

- (void)testNegativeMatchesWithPassingBlocks {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    expectFailureMessage(@"expected to raise exception that satisfies block, got no exception", ^{
        expect(exception).to(raiseException().
                             satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(@"LOL"));
        }));
    });

    NSString *outerFailureMessage = @"expected to raise exception that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).toNot(equal(NSInvalidArgumentException));
        }));
    });

    outerFailureMessage = @"expected to raise exception with name <foo> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(@"foo").
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(NSInvalidArgumentException));
        }));
    });

    outerFailureMessage = @"expected to raise exception with name <NSInvalidArgumentException> with reason <bar> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(NSInvalidArgumentException).
                                                 reason(@"bar").
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(NSInvalidArgumentException));
        }));
    });

    outerFailureMessage = @"expected to raise exception with name <NSInvalidArgumentException> with reason <No food> with userInfo <{}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(NSInvalidArgumentException).
                                                 reason(@"No food").
                                                 userInfo(@{}).
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(NSInvalidArgumentException));
        }));
    });
}

- (void)testNegativeMatchesWithNegativeBlocks {
    __block NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"No food"
                                                           userInfo:@{@"key": @"value"}];
    NSString *outerFailureMessage;

    NSString *const innerFailureMessage = @"expected to equal <foo>, got <NSInvalidArgumentException>";
    outerFailureMessage = @"expected to raise exception with name <NSInvalidArgumentException> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage, innerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(NSInvalidArgumentException).
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(@"foo"));
        }));
    });


    outerFailureMessage = @"expected to raise exception with name <NSInvalidArgumentException> with reason <No food> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage, innerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(NSInvalidArgumentException).
                                                 reason(@"No food").
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(@"foo"));
        }));
    });


    outerFailureMessage = @"expected to raise exception with name <NSInvalidArgumentException> with reason <No food> with userInfo <{key = value;}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: NSInvalidArgumentException), reason='No food', userInfo=[AnyHashable(\"key\"): value] }";
    expectFailureMessages((@[outerFailureMessage, innerFailureMessage]), ^{
        expectAction(^{ [exception raise]; }).to(raiseException().
                                                 named(NSInvalidArgumentException).
                                                 reason(@"No food").
                                                 userInfo(@{@"key": @"value"}).
                                                 satisfyingBlock(^(NSException *exception) {
            expect(exception.name).to(equal(@"foo"));
        }));
    });
}

@end
