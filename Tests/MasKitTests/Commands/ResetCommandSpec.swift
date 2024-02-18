//
//  ResetCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class ResetCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("reset command") {
            it("resets the App Store state") {
                let cmd = ResetCommand()
                let result = cmd.run(ResetCommand.Options(debug: false))
                expect(result).to(beSuccess())
            }
        }
    }
}
