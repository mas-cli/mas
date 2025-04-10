//
//  SignInSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

/// Deprecated test.
public final class SignInSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("signin command") {
            it("signs in") {
                expect(consequencesOf(try MAS.SignIn.parse(["", ""]).run()))
                    == (MASError.notSupported, "", "")
            }
        }
    }
}
