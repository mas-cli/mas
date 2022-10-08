//
//  OutdatedCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class OutdatedCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("outdated command") {
            it("displays apps with pending updates") {
                let cmd = OutdatedCommand()
                let result = cmd.run(OutdatedCommand.Options(verbose: true))
                print(result)
                expect(result).to(beSuccess())
            }
        }
    }
}
