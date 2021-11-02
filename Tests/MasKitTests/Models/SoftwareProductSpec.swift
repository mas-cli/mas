//
//  SoftwareProductSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 9/30/21.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import MasKit

public class SoftwareProductSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("software product") {
            let app = SoftwareProductMock(appName: "App", bundleIdentifier: "", bundlePath: "", bundleVersion: "1.0.0",
                                          itemIdentifier: 111)

            let currentApp = SearchResult(kind: "mac-software", version: "1.0.0")
            let appUpdate = SearchResult(kind: "mac-software", version: "2.0.0")
            let higherOs = SearchResult(kind: "mac-software", minimumOsVersion: "99.0.0", version: "3.0.0")
            let updateIos = SearchResult(kind: "software", minimumOsVersion: "99.0.0", version: "3.0.0")

            it("is not outdated when there is no new version available") {
                expect(app.isOutdatedWhenComparedTo(currentApp)) == false
            }
            it("is outdated when there is a new version available") {
                expect(app.isOutdatedWhenComparedTo(appUpdate)) == true
            }
            it("is not outdated when the new version requires a higher OS version") {
                expect(app.isOutdatedWhenComparedTo(higherOs)) == false
            }
            it("ignores minimum iOS version") {
                expect(app.isOutdatedWhenComparedTo(updateIos)) == true
            }
        }
    }
}
