//
//  MasAppLibrarySpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 3/1/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class MasAppLibrarySpec: QuickSpec {
    override func spec() {
        var library = MasAppLibrary()
        describe("mas app library") {
            it("contains all installed apps") {
                expect(library.installedApps).to(equal(apps)) 
//                expect(library.installedApps).to(contain(myApp))
            }
        }
    }
}

// MARK: - Test Data
let myApp = SoftwareProductMock(appName: "MyApp", bundleIdentifier: "com.example", bundlePath: "", bundleVersion: "", itemIdentifier: 1234)

var apps: [SoftwareProduct] = [
    myApp
]

// MARK: - SoftwareMapMock
struct SoftwareMapMock: SoftwareMap {
    var products: [SoftwareProduct] = []

    func allSoftwareProducts() -> [SoftwareProduct] {
        return products
    }

    func product(for bundleIdentifier: String) -> SoftwareProduct? {
        for product in products {
            if product.bundleIdentifier == bundleIdentifier {
                return product
            }
        }
        return nil
    }
}

//public func == (lhs: Expectation<[SoftwareProduct]>, rhs: [SoftwareProduct]) {
//    lhs.to(beCloseTo(rhs))
//}
