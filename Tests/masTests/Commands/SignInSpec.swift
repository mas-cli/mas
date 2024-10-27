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
public class SignInSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        // signin command disabled since macOS 10.13 High Sierra: https://github.com/mas-cli/mas#known-issues
        describe("signin command") {
            it("signs in") {
                expect {
                    try MAS.SignIn.parse(["", ""]).run()
                }
                .to(throwError(MASError.notSupported))
            }
        }
    }
}
