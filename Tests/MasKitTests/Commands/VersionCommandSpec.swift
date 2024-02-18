//
//  VersionCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class VersionCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("version command") {
            it("displays the current version") {
                let cmd = VersionCommand()
                let result = cmd.run(VersionCommand.Options())
                expect(result).to(beSuccess())
            }
        }
    }
}
