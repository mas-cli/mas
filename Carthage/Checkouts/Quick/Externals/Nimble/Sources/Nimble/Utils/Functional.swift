import Foundation

extension Sequence {
    internal func all(_ fn: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if !fn(item) {
                return false
            }
        }
        return true
    }
}
