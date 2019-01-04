//
//  SearchCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class SearchCommandSpec: QuickSpec {
    override func spec() {
        describe("search command") {
            it("updates stuff") {
                let cmd = SearchCommand()
                let result = cmd.run(SearchCommand.Options(appName: "", price: false))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
