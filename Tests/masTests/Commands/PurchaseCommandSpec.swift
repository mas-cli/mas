//
//  PurchaseCommandSpec.swift
//  masTests
//
//  Created by Maximilian Blochberger on 2020-03-21.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class PurchaseCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("purchase command") {
            it("purchases apps") {
                let cmd = PurchaseCommand()
                let result = cmd.run(PurchaseCommand.Options(appIds: []))
                expect(result).to(beSuccess())
            }
        }
    }
}
