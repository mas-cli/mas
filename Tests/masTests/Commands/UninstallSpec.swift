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

public class UninstallSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("uninstall command") {
            let appID: AppID = 12345
            let app = SoftwareProductMock(
                appName: "Some App",
                bundleIdentifier: "com.some.app",
                bundlePath: "/tmp/Some.app",
                bundleVersion: "1.0",
                itemIdentifier: NSNumber(value: appID)
            )
            let mockLibrary = AppLibraryMock()

            context("dry run") {
                let uninstall = try! Mas.Uninstall.parse(["--dry-run", String(appID)])

                beforeEach {
                    mockLibrary.reset()
                }
                it("can't remove a missing app") {
                    expect {
                        try uninstall.run(appLibrary: mockLibrary)
                    }
                    .to(throwError(MASError.notInstalled))
                }
                it("finds an app") {
                    mockLibrary.installedApps.append(app)
                    expect {
                        try uninstall.run(appLibrary: mockLibrary)
                    }
                    .toNot(throwError())
                }
            }
            context("wet run") {
                let uninstall = try! Mas.Uninstall.parse([String(appID)])

                beforeEach {
                    mockLibrary.reset()
                }
                it("can't remove a missing app") {
                    expect {
                        try uninstall.run(appLibrary: mockLibrary)
                    }
                    .to(throwError(MASError.notInstalled))
                }
                it("removes an app") {
                    mockLibrary.installedApps.append(app)
                    expect {
                        try captureStream(stdout) {
                            try uninstall.run(appLibrary: mockLibrary)
                        }
                    }
                        == "        1111  slack (0.0)\n==> Some App /tmp/Some.app\n==> (not removed, dry run)\n"
                }
                it("fails if there is a problem with the trash command") {
                    var brokenUninstall = app  // make mutable copy
                    brokenUninstall.bundlePath = "/dev/null"
                    mockLibrary.installedApps.append(brokenUninstall)
                    expect {
                        try uninstall.run(appLibrary: mockLibrary)
                    }
                    .to(throwError(MASError.uninstallFailed))
                }
            }
        }
    }
}
