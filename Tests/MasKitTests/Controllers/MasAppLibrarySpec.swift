//
//  MasAppLibrarySpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 3/1/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class MasAppLibrarySpec: QuickSpec {
    override public func spec() {
        let library = MasAppLibrary(softwareMap: SoftwareMapMock(products: apps))

        beforeSuite {
            MasKit.initialize()
        }
        describe("mas app library") {
            it("contains all installed apps") {
                expect(library.installedApps.count) == apps.count
                expect(library.installedApps.first!.appName) == myApp.appName
            }
            it("can locate an app by bundle id") {
                let app = library.installedApp(forBundleId: "com.example")!
                expect(app.bundleIdentifier) == myApp.bundleIdentifier
            }
        }
    }
}

// MARK: - Test Data
let myApp = SoftwareProductMock(
    appName: "MyApp",
    bundleIdentifier: "com.example",
    bundlePath: "",
    bundleVersion: "",
    itemIdentifier: 1234
)

var apps: [SoftwareProduct] = [myApp]

// MARK: - SoftwareMapMock
struct SoftwareMapMock: SoftwareMap {
    var products: [SoftwareProduct] = []

    func allSoftwareProducts() -> [SoftwareProduct] {
        products
    }

    func product(for bundleIdentifier: String) -> SoftwareProduct? {
        for product in products where product.bundleIdentifier == bundleIdentifier {
            return product
        }
        return nil
    }
}
