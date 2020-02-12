import Dispatch
import Foundation

/// "Global" state of Nimble is stored here. Only DSL functions should access / be aware of this
/// class' existence
internal class NimbleEnvironment: NSObject {
    static var activeInstance: NimbleEnvironment {
        get {
            let env = Thread.current.threadDictionary["NimbleEnvironment"]
            if let env = env as? NimbleEnvironment {
                return env
            } else {
                let newEnv = NimbleEnvironment()
                self.activeInstance = newEnv
                return newEnv
            }
        }
        set {
            Thread.current.threadDictionary["NimbleEnvironment"] = newValue
        }
    }

    // swiftlint:disable:next todo
    // TODO: eventually migrate the global to this environment value
    var assertionHandler: AssertionHandler {
        get { return NimbleAssertionHandler }
        set { NimbleAssertionHandler = newValue }
    }

    var suppressTVOSAssertionWarning: Bool = false
    var awaiter: Awaiter

    override init() {
        let timeoutQueue = DispatchQueue.global(qos: .userInitiated)
        awaiter = Awaiter(
            waitLock: AssertionWaitLock(),
            asyncQueue: .main,
            timeoutQueue: timeoutQueue
        )

        super.init()
    }
}
