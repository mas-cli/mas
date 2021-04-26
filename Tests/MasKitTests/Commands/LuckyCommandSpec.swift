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

class LuckyCommandSpec: QuickSpec {
    override func spec() {
        describe("lucky command") {
            it("installs the first app matching a search") {
                let cmd = LuckyCommand()
                let result = cmd.run(LuckyCommand.Options(appName: "", forceInstall: false))
                print(result)
                //                expect(result).to(beSuccess())
            }
        }
    }
}
