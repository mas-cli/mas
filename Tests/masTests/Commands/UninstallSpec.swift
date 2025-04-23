//
//  UninstallSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class UninstallSpec: QuickSpec {
    override public static func spec() {
        let appID = 12345 as AppID
        let app = SimpleInstalledApp(
            id: appID,
            name: "Some App",
            bundleID: "com.some.app",
            path: "/tmp/Some.app",
            version: "1.0"
        )

        xdescribe("uninstall command") {
            context("dry run") {
                it("can't remove a missing app") {
                    expect(
                        consequencesOf(
                            try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: [])
                        )
                    )
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("finds an app") {
                    expect(
                        consequencesOf(
                            try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: [app])
                        )
                    )
                        == (nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n", "")
                }
            }
            context("wet run") {
                it("can't remove a missing app") {
                    expect(
                        consequencesOf(
                            try MAS.Uninstall.parse([String(appID)]).run(installedApps: [])
                        )
                    )
                        == (MASError.notInstalled(appID: appID), "", "")
                }
                it("removes an app") {
                    expect(
                        consequencesOf(
                            try MAS.Uninstall.parse([String(appID)]).run(installedApps: [app])
                        )
                    )
                        == (nil, "", "")
                }
            }
        }
    }
}
