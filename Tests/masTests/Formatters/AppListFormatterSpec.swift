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
        let format = AppListFormatter.format(_:)

        describe("app list formatter") {
            it("formats nothing as empty string") {
                expect(consequencesOf(format([]))) == ("", nil, "", "")
            }
            it("can format a single installed app") {
                let installedApp = SimpleInstalledApp(
                    id: 12345,
                    name: "Awesome App",
                    bundleID: "",
                    path: "",
                    version: "19.2.1"
                )
                expect(consequencesOf(format([installedApp])))
                    == ("12345       Awesome App  (19.2.1)", nil, "", "")
            }
            it("can format two installed apps") {
                expect(
                    consequencesOf(
                        format(
                            [
                                SimpleInstalledApp(
                                    id: 12345,
                                    name: "Awesome App",
                                    bundleID: "",
                                    path: "",
                                    version: "19.2.1"
                                ),
                                SimpleInstalledApp(
                                    id: 67890,
                                    name: "Even Better App",
                                    bundleID: "",
                                    path: "",
                                    version: "1.2.0"
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
