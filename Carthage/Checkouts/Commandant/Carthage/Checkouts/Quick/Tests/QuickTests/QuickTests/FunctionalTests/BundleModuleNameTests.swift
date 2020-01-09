#if !SWIFT_PACKAGE

import XCTest
@testable import Quick
import Nimble

class BundleModuleNameSpecs: QuickSpec {
    override func spec() {
        describe("Bundle module name") {
            it("should repalce invalid characters with underscores") {
                let bundle = Bundle.currentTestBundle
                let moduleName = bundle?.moduleName
                expect(moduleName?.contains("Quick_")).to(beTrue())
            }

            it("should be the correct module name to be able to retreive classes") {
                guard let bundle = Bundle.currentTestBundle else {
                    XCTFail("test bundle not found")
                    return
                }

                let moduleName = bundle.moduleName
                let className: AnyClass? = NSClassFromString("\(moduleName).BundleModuleNameSpecs")
                expect(className).to(be(BundleModuleNameSpecs.self))
            }
        }
    }
}

#endif
