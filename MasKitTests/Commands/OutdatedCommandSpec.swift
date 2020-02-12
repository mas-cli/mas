//
//  OutdatedCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class OutdatedCommandSpec: QuickSpec {
    override func spec() {
        describe("outdated command") {
            it("displays apps with pending updates") {
                let cmd = OutdatedCommand()
                let result = cmd.run(OutdatedCommand.Options())
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
