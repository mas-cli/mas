//
//  ResetSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class ResetSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("reset command") {
            it("resets the App Store state") {
                expect {
                    try MAS.Reset.parse([]).run()
                }
                .toNot(throwError())
            }
        }
    }
}
