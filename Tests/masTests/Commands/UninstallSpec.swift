//
//  UninstallSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public final class UninstallSpec: QuickSpec {
    override public func spec() {
        let appID: AppID = 12345
        let app = MockSoftwareProduct(
            appName: "Some App",
            bundleIdentifier: "com.some.app",
            bundlePath: "/tmp/Some.app",
            bundleVersion: "1.0",
            itemIdentifier: NSNumber(value: appID)
        )

        beforeSuite {
            MAS.initialize()
        }
        xdescribe("uninstall command") {
            context("dry run") {
                let uninstall = try! MAS.Uninstall.parse(["--dry-run", String(appID)])

                it("can't remove a missing app") {
                    expect(consequencesOf(try uninstall.run(appLibrary: MockAppLibrary())))
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("finds an app") {
                    expect(consequencesOf(try uninstall.run(appLibrary: MockAppLibrary(app))))
                        == (nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n", "")
                }
            }
            context("wet run") {
                let uninstall = try! MAS.Uninstall.parse([String(appID)])

                it("can't remove a missing app") {
                    expect(consequencesOf(try uninstall.run(appLibrary: MockAppLibrary())))
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("removes an app") {
                    expect(consequencesOf(try uninstall.run(appLibrary: MockAppLibrary(app))))
                        == (nil, "", "")
                }
                it("fails if there is a problem with the trash command") {
                    var brokenApp = app
                    brokenApp.bundlePath = "/dev/null"
                    expect(consequencesOf(try uninstall.run(appLibrary: MockAppLibrary(brokenApp))))
                        == (MASError.uninstallFailed(error: nil), "", "")
                }
            }
        }
    }
}
