import Foundation

#if os(Linux)
    extension NSNotification.Name {
        init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
    }
#endif
