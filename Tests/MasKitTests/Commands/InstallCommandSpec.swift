//
//  InstallCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class InstallCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("install command") {
            it("installs apps") {
                let cmd = InstallCommand()
                let result = cmd.run(InstallCommand.Options(appIds: [], forceInstall: false))
                expect(result).to(beSuccess())
            }
        }
    }
}
