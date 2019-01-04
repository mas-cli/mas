//
//  ResetCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class ResetCommandSpec: QuickSpec {
    override func spec() {
        describe("reset command") {
            it("updates stuff") {
                let cmd = ResetCommand()
                let result = cmd.run(ResetCommand.Options(debug: false))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
