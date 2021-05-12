//
//  AccountCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class AccountCommandSpec: QuickSpec {
    public override func spec() {
        beforeSuite {
            MasKit.initialize()
        }
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
