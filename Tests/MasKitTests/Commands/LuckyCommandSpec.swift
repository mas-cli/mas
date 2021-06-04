//
//  LuckyCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class LuckyCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("lucky command") {
            xit("installs the first app matching a search") {
                let cmd = LuckyCommand()
                let result = cmd.run(LuckyCommand.Options(appName: "", forceInstall: false))
                expect(result).to(beSuccess())
            }
        }
    }
}
