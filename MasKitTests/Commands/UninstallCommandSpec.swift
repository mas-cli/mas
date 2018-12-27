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
            it("can't remove missing app") {
                let mockLibrary = MockAppLibrary()
                let uninstall = UninstallCommand(appLibrary: mockLibrary)
                let appId = 12345
                let options = UninstallCommand.Options(appId: appId, dryRun: true)

                let result = uninstall.run(options)
                print(result)
                expect(result).to(beFailure { error in
                    expect(error) == .notInstalled
                })
            }
        }
    }
}
