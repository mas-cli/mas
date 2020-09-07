#if canImport(CwlPreconditionTesting) && (os(macOS) || os(iOS))
import CwlPreconditionTesting
#elseif canImport(CwlPosixPreconditionTesting)
import CwlPosixPreconditionTesting
#endif

public func throwAssertion<Out>() -> Predicate<Out> {
    return Predicate { actualExpression in
    #if arch(x86_64) && canImport(Darwin)
        let message = ExpectationMessage.expectedTo("throw an assertion")

        var actualError: Error?
        let caughtException: BadInstructionException? = catchBadInstruction {
            #if os(tvOS)
                if !NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning {
                    print()
                    print("[Nimble Warning]: If you're getting stuck on a debugger breakpoint for a " +
                        "fatal error while using throwAssertion(), please disable 'Debug Executable' " +
                        "in your scheme. Go to 'Edit Scheme > Test > Info' and uncheck " +
                        "'Debug Executable'. If you've already done that, suppress this warning " +
                        "by setting `NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning = true`. " +
                        "This is required because the standard methods of catching assertions " +
                        "(mach APIs) are unavailable for tvOS. Instead, the same mechanism the " +
                        "debugger uses is the fallback method for tvOS."
                    )
                    print()
                    NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning = true
                }
            #endif
            do {
                _ = try actualExpression.evaluate()
            } catch {
                actualError = error
            }
        }

        if let actualError = actualError {
            return PredicateResult(
                bool: false,
                message: message.appended(message: "; threw error instead <\(actualError)>")
            )
        } else {
            return PredicateResult(bool: caughtException != nil, message: message)
        }
    #else
        fatalError("The throwAssertion Nimble matcher can only run on x86_64 platforms with " +
            "Objective-C (e.g. macOS, iPhone 5s or later simulators). You can silence this error " +
            "by placing the test case inside an #if arch(x86_64) or canImport(Darwin) conditional statement")
    #endif
    }
}
