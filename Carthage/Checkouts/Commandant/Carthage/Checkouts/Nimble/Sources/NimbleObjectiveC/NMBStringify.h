@class NSString;

/**
 * Returns a string appropriate for displaying in test output
 * from the provided value.
 *
 * @param anyObject A value that will show up in a test's output.
 *
 * @return The string that is returned can be
 *     customized per type by conforming a type to the `TestOutputStringConvertible`
 *     protocol. When stringifying a non-`TestOutputStringConvertible` type, this
 *     function will return the value's debug description and then its
 *     normal description if available and in that order. Otherwise it
 *     will return the result of constructing a string from the value.
 *
 * @see `TestOutputStringConvertible`
 */
extern NSString *_Nonnull NMBStringify(id _Nullable anyObject) __attribute__((warn_unused_result));
