//
//  AccountCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class AccountCommandSpec: QuickSpec {
    override func spec() {
        describe("Account command") {
            it("displays active account") {
                let cmd = AccountCommand()
                let result = cmd.run(AccountCommand.Options())
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
