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
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("uninstall command") {
            let appId = 12345
            let app = SoftwareProductMock(
                appName: "Some App",
                bundleIdentifier: "com.some.app",
                bundlePath: "/tmp/Some.app",
                bundleVersion: "1.0",
                itemIdentifier: NSNumber(value: appId)
            )
            let mockLibrary = AppLibraryMock()

            context("dry run") {
                let uninstall = try! Mas.Uninstall.parse(["--dry-run", String(appId)])

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
                let uninstall = try! Mas.Uninstall.parse([String(appId)])

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
                        try uninstall.run(appLibrary: mockLibrary)
                    }
                    .toNot(throwError())
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
