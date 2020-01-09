/**
    A container for closures to be executed before and after all examples.
*/
final internal class SuiteHooks {
    internal var befores: [BeforeSuiteClosure] = []
    internal var afters: [AfterSuiteClosure] = []
    internal var phase: HooksPhase = .nothingExecuted

    internal func appendBefore(_ closure: @escaping BeforeSuiteClosure) {
        befores.append(closure)
    }

    internal func appendAfter(_ closure: @escaping AfterSuiteClosure) {
        afters.append(closure)
    }

    internal func executeBefores() {
        phase = .beforesExecuting
        for before in befores {
            before()
        }
        phase = .beforesFinished
    }

    internal func executeAfters() {
        phase = .aftersExecuting
        for after in afters {
            after()
        }
        phase = .aftersFinished
    }
}
