#import <Nimble/DSL.h>

#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif


NS_ASSUME_NONNULL_BEGIN


NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBExpectation *__nonnull NMB_expect(id __nullable(^actualBlock)(void), NSString *__nonnull file, NSUInteger line) {
    return [[NMBExpectation alloc] initWithActualBlock:actualBlock
                                              negative:NO
                                                  file:file
                                                  line:line];
}

NIMBLE_EXPORT NMBExpectation *NMB_expectAction(void(^actualBlock)(void), NSString *file, NSUInteger line) {
    return NMB_expect(^id{
        actualBlock();
        return nil;
    }, file, line);
}

NIMBLE_EXPORT void NMB_failWithMessage(NSString *msg, NSString *file, NSUInteger line) {
    return [NMBExpectation failWithMessage:msg file:file line:line];
}

NIMBLE_EXPORT NMBPredicate *NMB_beAnInstanceOf(Class expectedClass) {
    return [NMBPredicate beAnInstanceOfMatcher:expectedClass];
}

NIMBLE_EXPORT NMBPredicate *NMB_beAKindOf(Class expectedClass) {
    return [NMBPredicate beAKindOfMatcher:expectedClass];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBObjCBeCloseToPredicate *NMB_beCloseTo(NSNumber *expectedValue) {
    return [NMBPredicate beCloseToMatcher:expectedValue within:0.001];
}

NIMBLE_EXPORT NMBPredicate *NMB_beginWith(id itemElementOrSubstring) {
    return [NMBPredicate beginWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_beGreaterThan(NSNumber *expectedValue) {
    return [NMBPredicate beGreaterThanMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_beGreaterThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBPredicate beGreaterThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT NMBPredicate *NMB_beIdenticalTo(id expectedInstance) {
    return [NMBPredicate beIdenticalToMatcher:expectedInstance];
}

NIMBLE_EXPORT NMBPredicate *NMB_be(id expectedInstance) {
    return [NMBPredicate beIdenticalToMatcher:expectedInstance];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_beLessThan(NSNumber *expectedValue) {
    return [NMBPredicate beLessThanMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_beLessThanOrEqualTo(NSNumber *expectedValue) {
    return [NMBPredicate beLessThanOrEqualToMatcher:expectedValue];
}

NIMBLE_EXPORT NMBPredicate *NMB_beTruthy() {
    return [NMBPredicate beTruthyMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_beFalsy() {
    return [NMBPredicate beFalsyMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_beTrue() {
    return [NMBPredicate beTrueMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_beFalse() {
    return [NMBPredicate beFalseMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_beNil() {
    return [NMBPredicate beNilMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_beEmpty() {
    return [NMBPredicate beEmptyMatcher];
}

NIMBLE_EXPORT NMBPredicate *NMB_containWithNilTermination(id itemOrSubstring, ...) {
    NSMutableArray *itemOrSubstringArray = [NSMutableArray array];

    if (itemOrSubstring) {
        [itemOrSubstringArray addObject:itemOrSubstring];

        va_list args;
        va_start(args, itemOrSubstring);
        id next;
        while ((next = va_arg(args, id))) {
            [itemOrSubstringArray addObject:next];
        }
        va_end(args);
    }

    return [NMBPredicate containMatcher:itemOrSubstringArray];
}

NIMBLE_EXPORT NMBPredicate *NMB_containElementSatisfying(BOOL(^predicate)(id)) {
    return [NMBPredicate containElementSatisfyingMatcher:predicate];
}

NIMBLE_EXPORT NMBPredicate *NMB_endWith(id itemElementOrSubstring) {
    return [NMBPredicate endWithMatcher:itemElementOrSubstring];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_equal(__nullable id expectedValue) {
    return [NMBPredicate equalMatcher:expectedValue];
}

NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBPredicate *NMB_haveCount(id expectedValue) {
    return [NMBPredicate haveCountMatcher:expectedValue];
}

NIMBLE_EXPORT NMBPredicate *NMB_match(id expectedValue) {
    return [NMBPredicate matchMatcher:expectedValue];
}

NIMBLE_EXPORT NMBPredicate *NMB_allPass(id expectedValue) {
    return [NMBPredicate allPassMatcher:expectedValue];
}

NIMBLE_EXPORT NMBPredicate *NMB_satisfyAnyOfWithMatchers(id matchers) {
    return [NMBPredicate satisfyAnyOfMatcher:matchers];
}

NIMBLE_EXPORT NMBPredicate *NMB_satisfyAllOfWithMatchers(id matchers) {
    return [NMBPredicate satisfyAllOfMatcher:matchers];
}

NIMBLE_EXPORT NMBObjCRaiseExceptionPredicate *NMB_raiseException() {
    return [NMBPredicate raiseExceptionMatcher];
}

NIMBLE_EXPORT NMBWaitUntilTimeoutBlock NMB_waitUntilTimeoutBuilder(NSString *file, NSUInteger line) {
    return ^(NSTimeInterval timeout, void (^ _Nonnull action)(void (^ _Nonnull)(void))) {
        [NMBWait untilTimeout:timeout file:file line:line action:action];
    };
}

NIMBLE_EXPORT NMBWaitUntilBlock NMB_waitUntilBuilder(NSString *file, NSUInteger line) {
  return ^(void (^ _Nonnull action)(void (^ _Nonnull)(void))) {
    [NMBWait untilFile:file line:line action:action];
  };
}

NS_ASSUME_NONNULL_END
