//
//  AccountSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class AccountSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("account command") {
            it("displays not supported warning") {
                expect(consequencesOf(try MAS.Account.parse([]).run()))
                    == (error: MASError.notSupported, stdout: "", stderr: "")
            }
        }
    }
}
