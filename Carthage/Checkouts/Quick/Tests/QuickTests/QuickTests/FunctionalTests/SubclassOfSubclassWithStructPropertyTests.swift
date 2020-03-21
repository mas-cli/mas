import XCTest
import Quick

// The regression test for https://github.com/Quick/Quick/issues/853

class FunctionalTests_SubclassSpec: QuickSpec {}
class FunctionalTests_SubclassOfSubclassWithStructPropertySpec: FunctionalTests_SubclassSpec {
    let date = Date()

    override func spec() {}
}
