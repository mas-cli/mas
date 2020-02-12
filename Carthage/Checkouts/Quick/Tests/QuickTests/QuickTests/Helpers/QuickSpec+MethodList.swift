#if canImport(Darwin)
import Foundation
import Quick

extension QuickSpec {
    @objc static func allSelectors() -> Set<String> {
        var allSelectors = Set<String>()

        var methodCount: UInt32 = 0
        guard let methodList = class_copyMethodList(self, &methodCount) else {
            return []
        }
        defer { free(methodList) }

        for i in 0..<Int(methodCount) {
            let method = methodList[i]
            let selector = method_getName(method)
            allSelectors.insert(NSStringFromSelector(selector))
        }

        return allSelectors
    }
}
#endif
