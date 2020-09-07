import XCTest
import Quick

// The regression test for https://github.com/Quick/Quick/issues/853
//
// Don't change the classes definition order to mimic the situation in https://github.com/gzafra/QuickCrashTest.

class SubclassOfSubclassWithStructPropertySpec: SubclassSpec {
    let date = Date()

    override func spec() {
        it("should not crash") {}
    }
}

class SubclassSpec: QuickSpec {
    override func spec() {
        it("should not crash") {}
    }
}
