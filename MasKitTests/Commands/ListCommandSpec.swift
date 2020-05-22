//
//  ListCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class ListCommandSpec: QuickSpec {
    override func spec() {
        describe("list command") {
            it("lists stuff") {
                let list = ListCommand()
                let result = list.run(ListCommand.Options())
                print(result)
                expect(result).to(beSuccess())
            }
        }
    }
}
