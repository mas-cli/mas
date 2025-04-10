//
//  SignOutSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class SignOutSpec: QuickSpec {
    override public static func spec() {
        describe("signout command") {
            it("signs out") {
                expect(consequencesOf(try MAS.SignOut.parse([]).run()))
                    == (nil, "", "")
            }
        }
    }
}
