import Foundation

#if !swift(>=4.2)
extension Sequence {
    internal func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for item in self {
            if try !predicate(item) {
                return false
            }
        }
        return true
    }
}
#endif
