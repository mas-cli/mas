//
//  InstallCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick
import Result

class InstallCommandSpec: QuickSpec {
    override func spec() {
        describe("install command") {
            it("installs apps") {
                let cmd = InstallCommand()
                let result = cmd.run(InstallCommand.Options(appIds: [], forceInstall: false))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
