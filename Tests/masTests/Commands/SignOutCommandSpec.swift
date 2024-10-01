//
//  SignOutCommandSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class SignOutCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("signout command") {
            it("signs out") {
                let cmd = SignOutCommand()
                let result = cmd.run(SignOutCommand.Options())
                expect(result).to(beSuccess())
            }
        }
    }
}
