//
//  UninstallCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import MasKit

class UninstallCommandSpec: QuickSpec {
    override func spec() {
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
            let uninstall = UninstallCommand(appLibrary: mockLibrary)

            context("dry run") {
                let options = UninstallCommand.Options(appId: appId, dryRun: true)

                beforeEach {
                    mockLibrary.reset()
                }
                it("can't remove a missing app") {
                    let result = uninstall.run(options)
                    expect(result)
                        .to(
                            beFailure { error in
                                expect(error) == .notInstalled
                            })
                }
                it("finds an app") {
                    mockLibrary.installedApps.append(app)

                    let result = uninstall.run(options)
                    expect(result).to(beSuccess())
                }
            }
            context("wet run") {
                let options = UninstallCommand.Options(appId: appId, dryRun: false)

                beforeEach {
                    mockLibrary.reset()
                }
                it("can't remove a missing app") {
                    let result = uninstall.run(options)
                    expect(result)
                        .to(
                            beFailure { error in
                                expect(error) == .notInstalled
                            })
                }
                it("removes an app") {
                    mockLibrary.installedApps.append(app)

                    let result = uninstall.run(options)
                    expect(result).to(beSuccess())
                }
                it("fails if there is a problem with the trash command") {
                    var brokenUninstall = app  // make mutable copy
                    brokenUninstall.bundlePath = "/dev/null"
                    mockLibrary.installedApps.append(brokenUninstall)

                    let result = uninstall.run(options)
                    expect(result)
                        .to(
                            beFailure { error in
                                expect(error) == .uninstallFailed
                            })
                }
            }
        }
    }
}
