import Dispatch

#if canImport(CDispatch)
import CDispatch
#endif

extension DispatchTimeInterval {
    // ** Note: We cannot simply divide the time interval because DispatchTimeInterval associated value type is Int
    var divided: DispatchTimeInterval {
        switch self {
        case let .seconds(val): return val < 2 ? .milliseconds(Int(Float(val)/2*1000)) : .seconds(val/2)
        case let .milliseconds(val): return .milliseconds(val/2)
        case let .microseconds(val): return .microseconds(val/2)
        case let .nanoseconds(val): return .nanoseconds(val/2)
        case .never: return .never
        @unknown default: fatalError("Unknown DispatchTimeInterval value")
        }
    }

    var description: String {
        switch self {
        case let .seconds(val): return val == 1 ? "\(Float(val)) second" : "\(Float(val)) seconds"
        case let .milliseconds(val): return "\(Float(val)/1_000) seconds"
        case let .microseconds(val): return "\(Float(val)/1_000_000) seconds"
        case let .nanoseconds(val): return "\(Float(val)/1_000_000_000) seconds"
        default: fatalError("Unknown DispatchTimeInterval value")
        }
    }
}

#if canImport(Foundation)
import typealias Foundation.TimeInterval

extension TimeInterval {
    var dispatchInterval: DispatchTimeInterval {
        let microseconds = Int64(self * TimeInterval(USEC_PER_SEC))
        // perhaps use nanoseconds, though would more often be > Int.max
        return microseconds < Int.max ? .microseconds(Int(microseconds)) : .seconds(Int(self))
    }
}
#endif
