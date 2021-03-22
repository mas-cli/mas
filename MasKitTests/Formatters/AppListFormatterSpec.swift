//
//  AppListFormatterSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 8/23/2020.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

class AppListsFormatterSpec: QuickSpec {
    override func spec() {
        // static func reference
        let format = AppListFormatter.format(products:)
        var products: [SoftwareProduct] = []

        describe("app list formatter") {
            beforeEach {
                products = []
            }
            it("formats nothing as empty string") {
                let output = format(products)
                expect(output) == ""
            }
            it("can format a single product") {
                let product = SoftwareProductMock(
                    appName: "Awesome App",
                    bundleIdentifier: "",
                    bundlePath: "",
                    bundleVersion: "19.2.1",
                    itemIdentifier: 12345
                )
                let output = format([product])
                expect(output) == "12345       Awesome App  (19.2.1)"
            }
            it("can format two products") {
                products = [
                    SoftwareProductMock(
                        appName: "Awesome App",
                        bundleIdentifier: "",
                        bundlePath: "",
                        bundleVersion: "19.2.1",
                        itemIdentifier: 12345
                    ),
                    SoftwareProductMock(
                        appName: "Even Better App",
                        bundleIdentifier: "",
                        bundlePath: "",
                        bundleVersion: "1.2.0",
                        itemIdentifier: 67890
                    ),
                ]
                let output = format(products)
                expect(output) == "12345       Awesome App      (19.2.1)\n67890       Even Better App  (1.2.0)"
            }
        }
    }
}
