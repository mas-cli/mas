//
//  UninstallCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class UninstallCommandSpec: QuickSpec {
    override func spec() {
        describe("uninstall command") {
            let appId = 12345
            let app = MockSoftwareProduct(
                appName: "Some App",
                bundlePath: "/tmp/Some.app",
                itemIdentifier: NSNumber(value: appId)
            )
            let mockLibrary = MockAppLibrary()
            let uninstall = UninstallCommand(appLibrary: mockLibrary)

            context("dry run") {
                let options = UninstallCommand.Options(appId: appId, dryRun: true)

                it("can't remove a missing app") {
                    mockLibrary.apps = []

                    let result = uninstall.run(options)
                    expect(result).to(beFailure { error in
                        expect(error) == .notInstalled
                    })
                }
                it("finds an app") {
                    mockLibrary.apps.append(app)

                    let result = uninstall.run(options)
                    expect(result).to(beSuccess())
                }
            }
            context("wet run") {
                let options = UninstallCommand.Options(appId: appId, dryRun: false)

                it("can't remove a missing app") {
                    mockLibrary.apps = []

                    let result = uninstall.run(options)
                    expect(result).to(beFailure { error in
                        expect(error) == .notInstalled
                    })
                }
                it("removes an app") {
                    mockLibrary.apps.append(app)

                    let result = uninstall.run(options)
                    expect(result).to(beSuccess())
                }
                it("fails if there is a problem with the trash command") {
                    mockLibrary.apps = []
                    var brokenUninstall = app // make mutable copy
                    brokenUninstall.bundlePath = "/dev/null"
                    mockLibrary.apps.append(brokenUninstall)

                    let result = uninstall.run(options)
                    expect(result).to(beFailure { error in
                        expect(error) == .uninstallFailed
                    })
                }
            }
        }
    }
}
