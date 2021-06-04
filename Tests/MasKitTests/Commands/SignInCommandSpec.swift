//
//  SignInCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class SignInCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("signin command") {
            xit("signs in") {
                let cmd = SignInCommand()
                let result = cmd.run(SignInCommand.Options(username: "", password: "", dialog: false))
                expect(result).to(beSuccess())
            }
        }
    }
}
