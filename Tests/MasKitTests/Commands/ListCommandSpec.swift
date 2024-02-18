//
//  ListCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class ListCommandSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MasKit.initialize()
        }
        describe("list command") {
            it("lists apps") {
                let list = ListCommand()
                let result = list.run(ListCommand.Options())
                expect(result).to(beSuccess())
            }
        }
    }
}
