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

// Deprecated test
public class AccountCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        // account command disabled since macOS 12 Monterey https://github.com/mas-cli/mas#%EF%B8%8F-known-issues
        xdescribe("Account command") {
            xit("displays active account") {
                let cmd = AccountCommand()
                let result = cmd.run(AccountCommand.Options())
                expect(result).to(beSuccess())
            }
        }
    }
}
