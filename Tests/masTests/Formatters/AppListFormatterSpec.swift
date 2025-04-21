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

public final class AppListFormatterSpec: QuickSpec {
    override public static func spec() {
        // static func reference
        let format = AppListFormatter.format(products:)

        describe("app list formatter") {
            it("formats nothing as empty string") {
                expect(consequencesOf(format([]))) == ("", nil, "", "")
            }
            it("can format a single product") {
                let product = SimpleSoftwareProduct(
                    appID: 12345,
                    appName: "Awesome App",
                    bundleIdentifier: "",
                    bundlePath: "",
                    bundleVersion: "19.2.1"
                )
                expect(consequencesOf(format([product])))
                    == ("12345       Awesome App  (19.2.1)", nil, "", "")
            }
            it("can format two products") {
                expect(
                    consequencesOf(
                        format(
                            [
                                SimpleSoftwareProduct(
                                    appID: 12345,
                                    appName: "Awesome App",
                                    bundleIdentifier: "",
                                    bundlePath: "",
                                    bundleVersion: "19.2.1"
                                ),
                                SimpleSoftwareProduct(
                                    appID: 67890,
                                    appName: "Even Better App",
                                    bundleIdentifier: "",
                                    bundlePath: "",
                                    bundleVersion: "1.2.0"
                                ),
                            ]
                        )
                    )
                )
                    == ("12345       Awesome App      (19.2.1)\n67890       Even Better App  (1.2.0)", nil, "", "")
            }
        }
    }
}
