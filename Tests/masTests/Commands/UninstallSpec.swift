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

public final class UninstallSpec: AsyncSpec {
    override public static func spec() {
        let appID = 12345 as AppID
        let app = SimpleSoftwareProduct(
            appID: appID,
            appName: "Some App",
            bundleIdentifier: "com.some.app",
            bundlePath: "/tmp/Some.app",
            bundleVersion: "1.0"
        )

        xdescribe("uninstall command") {
            context("dry run") {
                it("can't remove a missing app") {
                    await expecta(
                        await consequencesOf(
                            try await MAS.Uninstall.parse(["--dry-run", String(appID)])
                                .run(appLibrary: MockAppLibrary())
                        )
                    )
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("finds an app") {
                    await expecta(
                        await consequencesOf(
                            try await MAS.Uninstall.parse(["--dry-run", String(appID)])
                                .run(appLibrary: MockAppLibrary(app))
                        )
                    )
                        == (nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n", "")
                }
            }
            context("wet run") {
                it("can't remove a missing app") {
                    await expecta(
                        await consequencesOf(
                            try await MAS.Uninstall.parse([String(appID)]).run(appLibrary: MockAppLibrary())
                        )
                    )
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("removes an app") {
                    await expecta(
                        await consequencesOf(
                            try await MAS.Uninstall.parse([String(appID)]).run(appLibrary: MockAppLibrary(app))
                        )
                    )
                        == (nil, "", "")
                }
                it("fails if there is a problem with the trash command") {
                    var brokenApp = app
                    brokenApp.bundlePath = "/dev/null"
                    await expecta(
                        await consequencesOf(
                            try await MAS.Uninstall.parse([String(appID)]).run(appLibrary: MockAppLibrary(brokenApp))
                        )
                    )
                        == (MASError.uninstallFailed(error: nil), "", "")
                }
            }
        }
    }
}
