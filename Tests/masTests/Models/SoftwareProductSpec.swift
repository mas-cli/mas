//
//  SoftwareProductSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 9/30/21.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class SoftwareProductSpec: AsyncSpec {
    override public static func spec() {
        let app = SimpleSoftwareProduct(
            appID: 111,
            appName: "App",
            bundleIdentifier: "",
            bundlePath: "",
            bundleVersion: "1.0.0"
        )

        describe("software product") {
            it("is not outdated when there is no new version available") {
                await expecta(await consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "1.0.0"))))
                    == (false, nil, "", "")
            }
            it("is outdated when there is a new version available") {
                await expecta(await consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "2.0.0"))))
                    == (true, nil, "", "")
            }
            it("is not outdated when the new version of mac-software requires a higher OS version") {
                await expecta(
                    await consequencesOf(
                        app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0"))
                    )
                )
                    == (false, nil, "", "")
            }
            it("is not outdated when the new version of software requires a higher OS version") {
                await expecta(
                    await consequencesOf(
                        app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0"))
                    )
                )
                    == (false, nil, "", "")
            }
        }
    }
}
