#import <Foundation/Foundation.h>

@class NMBExpectation;
@class NMBPredicate;
@class NMBObjCBeCloseToPredicate;
@class NMBObjCRaiseExceptionPredicate;


NS_ASSUME_NONNULL_BEGIN


#define NIMBLE_OVERLOADABLE __attribute__((overloadable))
#define NIMBLE_EXPORT FOUNDATION_EXPORT
#define NIMBLE_EXPORT_INLINE FOUNDATION_STATIC_INLINE

#define NIMBLE_VALUE_OF(VAL) ({ \
    __typeof__((VAL)) val = (VAL); \
    [NSValue valueWithBytes:&val objCType:@encode(__typeof__((VAL)))]; \
})

#ifdef NIMBLE_DISABLE_SHORT_SYNTAX
#define NIMBLE_SHORT(PROTO, ORIGINAL)
#define NIMBLE_SHORT_OVERLOADED(PROTO, ORIGINAL)
#else
#define NIMBLE_SHORT(PROTO, ORIGINAL) FOUNDATION_STATIC_INLINE PROTO { return (ORIGINAL); }
#define NIMBLE_SHORT_OVERLOADED(PROTO, ORIGINAL) FOUNDATION_STATIC_INLINE NIMBLE_OVERLOADABLE PROTO { return (ORIGINAL); }
#endif



#define DEFINE_NMB_EXPECT_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBExpectation *NMB_expect(TYPE(^actualBlock)(void), NSString *file, NSUInteger line) { \
            return NMB_expect(^id { return EXPR; }, file, line); \
        }

    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBExpectation *NMB_expect(id(^actualBlock)(void), NSString *file, NSUInteger line);

    // overloaded dispatch for nils - expect(nil)
    DEFINE_NMB_EXPECT_OVERLOAD(void*, nil)
    DEFINE_NMB_EXPECT_OVERLOAD(NSRange, NIMBLE_VALUE_OF(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(long, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(unsigned long, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(int, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(unsigned int, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(float, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(double, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(long long, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(unsigned long long, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(char, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(unsigned char, @(actualBlock()))
    // bool doesn't get the compiler to dispatch to BOOL types, but using BOOL here seems to allow
    // the compiler to dispatch to bool.
    DEFINE_NMB_EXPECT_OVERLOAD(BOOL, @(actualBlock()))
    DEFINE_NMB_EXPECT_OVERLOAD(char *, @(actualBlock()))


#undef DEFINE_NMB_EXPECT_OVERLOAD



NIMBLE_EXPORT NMBExpectation *NMB_expectAction(void(^actualBlock)(void), NSString *file, NSUInteger line);



#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBPredicate *NMB_equal(TYPE expectedValue) { \
            return NMB_equal((EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBPredicate *equal(TYPE expectedValue), NMB_equal(expectedValue));


    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_equal(__nullable id expectedValue);

    NIMBLE_SHORT_OVERLOADED(NMBPredicate *equal(__nullable id expectedValue),
                            NMB_equal(expectedValue));

    // overloaded dispatch for nils - expect(nil)
    DEFINE_OVERLOAD(void*__nullable, (id)nil)
    DEFINE_OVERLOAD(NSRange, NIMBLE_VALUE_OF(expectedValue))
    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))
    // bool doesn't get the compiler to dispatch to BOOL types, but using BOOL here seems to allow
    // the compiler to dispatch to bool.
    DEFINE_OVERLOAD(BOOL, @(expectedValue))
    DEFINE_OVERLOAD(char *, @(expectedValue))

#undef DEFINE_OVERLOAD


#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBPredicate *NMB_haveCount(TYPE expectedValue) { \
            return NMB_haveCount((EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBPredicate *haveCount(TYPE expectedValue), \
            NMB_haveCount(expectedValue));


    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_haveCount(id expectedValue);

    NIMBLE_SHORT_OVERLOADED(NMBPredicate *haveCount(id expectedValue),
                            NMB_haveCount(expectedValue));

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))

#undef DEFINE_OVERLOAD

#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBObjCBeCloseToPredicate *NMB_beCloseTo(TYPE expectedValue) { \
            return NMB_beCloseTo((NSNumber *)(EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBObjCBeCloseToPredicate *beCloseTo(TYPE expectedValue), \
            NMB_beCloseTo(expectedValue));

    NIMBLE_EXPORT NIMBLE_OVERLOADABLE NMBObjCBeCloseToPredicate *NMB_beCloseTo(NSNumber *expectedValue);
    NIMBLE_SHORT_OVERLOADED(NMBObjCBeCloseToPredicate *beCloseTo(NSNumber *expectedValue),
                            NMB_beCloseTo(expectedValue));

    // it would be better to only overload float & double, but zero becomes ambigious

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))

#undef DEFINE_OVERLOAD

NIMBLE_EXPORT NMBPredicate *NMB_beAnInstanceOf(Class expectedClass);
NIMBLE_EXPORT_INLINE NMBPredicate *beAnInstanceOf(Class expectedClass) {
    return NMB_beAnInstanceOf(expectedClass);
}

NIMBLE_EXPORT NMBPredicate *NMB_beAKindOf(Class expectedClass);
NIMBLE_EXPORT_INLINE NMBPredicate *beAKindOf(Class expectedClass) {
    return NMB_beAKindOf(expectedClass);
}

NIMBLE_EXPORT NMBPredicate *NMB_beginWith(id itemElementOrSubstring);
NIMBLE_EXPORT_INLINE NMBPredicate *beginWith(id itemElementOrSubstring) {
    return NMB_beginWith(itemElementOrSubstring);
}

#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBPredicate *NMB_beGreaterThan(TYPE expectedValue) { \
            return NMB_beGreaterThan((EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBPredicate *beGreaterThan(TYPE expectedValue), NMB_beGreaterThan(expectedValue));

    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_beGreaterThan(NSNumber *expectedValue);

    NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE
    NMBPredicate *beGreaterThan(NSNumber *expectedValue) {
        return NMB_beGreaterThan(expectedValue);
    }

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))

#undef DEFINE_OVERLOAD

#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBPredicate *NMB_beGreaterThanOrEqualTo(TYPE expectedValue) { \
            return NMB_beGreaterThanOrEqualTo((EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBPredicate *beGreaterThanOrEqualTo(TYPE expectedValue), \
            NMB_beGreaterThanOrEqualTo(expectedValue));

    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_beGreaterThanOrEqualTo(NSNumber *expectedValue);

    NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE
    NMBPredicate *beGreaterThanOrEqualTo(NSNumber *expectedValue) {
        return NMB_beGreaterThanOrEqualTo(expectedValue);
    }

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))


#undef DEFINE_OVERLOAD

NIMBLE_EXPORT NMBPredicate *NMB_beIdenticalTo(id expectedInstance);
NIMBLE_SHORT(NMBPredicate *beIdenticalTo(id expectedInstance),
             NMB_beIdenticalTo(expectedInstance));

NIMBLE_EXPORT NMBPredicate *NMB_be(id expectedInstance);
NIMBLE_SHORT(NMBPredicate *be(id expectedInstance),
             NMB_be(expectedInstance));


#define DEFINE_OVERLOAD(TYPE, EXPR) \
        NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
        NMBPredicate *NMB_beLessThan(TYPE expectedValue) { \
            return NMB_beLessThan((EXPR)); \
        } \
        NIMBLE_SHORT_OVERLOADED(NMBPredicate *beLessThan(TYPE expectedValue), \
            NMB_beLessThan(expectedValue));

    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_beLessThan(NSNumber *expectedValue);

    NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE
    NMBPredicate *beLessThan(NSNumber *expectedValue) {
        return NMB_beLessThan(expectedValue);
    }

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))

#undef DEFINE_OVERLOAD


#define DEFINE_OVERLOAD(TYPE, EXPR) \
    NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE \
    NMBPredicate *NMB_beLessThanOrEqualTo(TYPE expectedValue) { \
        return NMB_beLessThanOrEqualTo((EXPR)); \
    } \
    NIMBLE_SHORT_OVERLOADED(NMBPredicate *beLessThanOrEqualTo(TYPE expectedValue), \
        NMB_beLessThanOrEqualTo(expectedValue));


    NIMBLE_EXPORT NIMBLE_OVERLOADABLE
    NMBPredicate *NMB_beLessThanOrEqualTo(NSNumber *expectedValue);

    NIMBLE_EXPORT_INLINE NIMBLE_OVERLOADABLE
    NMBPredicate *beLessThanOrEqualTo(NSNumber *expectedValue) {
        return NMB_beLessThanOrEqualTo(expectedValue);
    }

    DEFINE_OVERLOAD(long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long, @(expectedValue))
    DEFINE_OVERLOAD(int, @(expectedValue))
    DEFINE_OVERLOAD(unsigned int, @(expectedValue))
    DEFINE_OVERLOAD(float, @(expectedValue))
    DEFINE_OVERLOAD(double, @(expectedValue))
    DEFINE_OVERLOAD(long long, @(expectedValue))
    DEFINE_OVERLOAD(unsigned long long, @(expectedValue))
    DEFINE_OVERLOAD(char, @(expectedValue))
    DEFINE_OVERLOAD(unsigned char, @(expectedValue))

#undef DEFINE_OVERLOAD

NIMBLE_EXPORT NMBPredicate *NMB_beTruthy(void);
NIMBLE_SHORT(NMBPredicate *beTruthy(void),
             NMB_beTruthy());

NIMBLE_EXPORT NMBPredicate *NMB_beFalsy(void);
NIMBLE_SHORT(NMBPredicate *beFalsy(void),
             NMB_beFalsy());

NIMBLE_EXPORT NMBPredicate *NMB_beTrue(void);
NIMBLE_SHORT(NMBPredicate *beTrue(void),
             NMB_beTrue());

NIMBLE_EXPORT NMBPredicate *NMB_beFalse(void);
NIMBLE_SHORT(NMBPredicate *beFalse(void),
             NMB_beFalse());

NIMBLE_EXPORT NMBPredicate *NMB_beNil(void);
NIMBLE_SHORT(NMBPredicate *beNil(void),
             NMB_beNil());

NIMBLE_EXPORT NMBPredicate *NMB_beEmpty(void);
NIMBLE_SHORT(NMBPredicate *beEmpty(void),
             NMB_beEmpty());

NIMBLE_EXPORT NMBPredicate *NMB_containWithNilTermination(id itemOrSubstring, ...) NS_REQUIRES_NIL_TERMINATION;
#define NMB_contain(...) NMB_containWithNilTermination(__VA_ARGS__, nil)
#ifndef NIMBLE_DISABLE_SHORT_SYNTAX
#define contain(...) NMB_contain(__VA_ARGS__)
#endif

NIMBLE_EXPORT NMBPredicate *NMB_containElementSatisfying(BOOL(^predicate)(id));
NIMBLE_SHORT(NMBPredicate *containElementSatisfying(BOOL(^predicate)(id)),
             NMB_containElementSatisfying(predicate));

NIMBLE_EXPORT NMBPredicate *NMB_endWith(id itemElementOrSubstring);
NIMBLE_SHORT(NMBPredicate *endWith(id itemElementOrSubstring),
             NMB_endWith(itemElementOrSubstring));

NIMBLE_EXPORT NMBObjCRaiseExceptionPredicate *NMB_raiseException(void);
NIMBLE_SHORT(NMBObjCRaiseExceptionPredicate *raiseException(void),
             NMB_raiseException());

NIMBLE_EXPORT NMBPredicate *NMB_match(id expectedValue);
NIMBLE_SHORT(NMBPredicate *match(id expectedValue),
             NMB_match(expectedValue));

NIMBLE_EXPORT NMBPredicate *NMB_allPass(id matcher);
NIMBLE_SHORT(NMBPredicate *allPass(id matcher),
             NMB_allPass(matcher));

NIMBLE_EXPORT NMBPredicate *NMB_satisfyAnyOfWithMatchers(id matchers);
#define NMB_satisfyAnyOf(...) NMB_satisfyAnyOfWithMatchers(@[__VA_ARGS__])
#ifndef NIMBLE_DISABLE_SHORT_SYNTAX
#define satisfyAnyOf(...) NMB_satisfyAnyOf(__VA_ARGS__)
#endif

NIMBLE_EXPORT NMBPredicate *NMB_satisfyAllOfWithMatchers(id matchers);
#define NMB_satisfyAllOf(...) NMB_satisfyAllOfWithMatchers(@[__VA_ARGS__])
#ifndef NIMBLE_DISABLE_SHORT_SYNTAX
#define satisfyAllOf(...) NMB_satisfyAllOf(__VA_ARGS__)
#endif

// In order to preserve breakpoint behavior despite using macros to fill in __FILE__ and __LINE__,
// define a builder that populates __FILE__ and __LINE__, and returns a block that takes timeout
// and action arguments. See https://github.com/Quick/Quick/pull/185 for details.
typedef void (^NMBWaitUntilTimeoutBlock)(NSTimeInterval timeout, void (^action)(void (^)(void)));
typedef void (^NMBWaitUntilBlock)(void (^action)(void (^)(void)));

NIMBLE_EXPORT void NMB_failWithMessage(NSString *msg, NSString *file, NSUInteger line);

NIMBLE_EXPORT NMBWaitUntilTimeoutBlock NMB_waitUntilTimeoutBuilder(NSString *file, NSUInteger line);
NIMBLE_EXPORT NMBWaitUntilBlock NMB_waitUntilBuilder(NSString *file, NSUInteger line);

NIMBLE_EXPORT void NMB_failWithMessage(NSString *msg, NSString *file, NSUInteger line);

#define NMB_waitUntilTimeout NMB_waitUntilTimeoutBuilder(@(__FILE__), __LINE__)
#define NMB_waitUntil NMB_waitUntilBuilder(@(__FILE__), __LINE__)

#ifndef NIMBLE_DISABLE_SHORT_SYNTAX
#define expect(...) NMB_expect(^{ return (__VA_ARGS__); }, @(__FILE__), __LINE__)
#define expectAction(BLOCK) NMB_expectAction((BLOCK), @(__FILE__), __LINE__)
#define failWithMessage(msg) NMB_failWithMessage(msg, @(__FILE__), __LINE__)
#define fail() failWithMessage(@"fail() always fails")


#define waitUntilTimeout NMB_waitUntilTimeout
#define waitUntil NMB_waitUntil

#undef NIMBLE_VALUE_OF

#endif

NS_ASSUME_NONNULL_END
