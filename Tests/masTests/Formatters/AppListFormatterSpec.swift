//
//  AppListFormatterSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 8/23/2020.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class AppListFormatterSpec: QuickSpec {
    override public func spec() {
        // static func reference
        let format = AppListFormatter.format(products:)

        beforeSuite {
            MAS.initialize()
        }
        describe("app list formatter") {
            it("formats nothing as empty string") {
                expect(format([])).to(beEmpty())
            }
            it("can format a single product") {
                let product = MockSoftwareProduct(
                    appName: "Awesome App",
                    bundleIdentifier: "",
                    bundlePath: "",
                    bundleVersion: "19.2.1",
                    itemIdentifier: 12345
                )
                expect(format([product])) == "12345       Awesome App  (19.2.1)"
            }
            it("can format two products") {
                expect(
                    format(
                        [
                            MockSoftwareProduct(
                                appName: "Awesome App",
                                bundleIdentifier: "",
                                bundlePath: "",
                                bundleVersion: "19.2.1",
                                itemIdentifier: 12345
                            ),
                            MockSoftwareProduct(
                                appName: "Even Better App",
                                bundleIdentifier: "",
                                bundlePath: "",
                                bundleVersion: "1.2.0",
                                itemIdentifier: 67890
                            ),
                        ]
                    )
                )
                    == "12345       Awesome App      (19.2.1)\n67890       Even Better App  (1.2.0)"
            }
        }
    }
}
