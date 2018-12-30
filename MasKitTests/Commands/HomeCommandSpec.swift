//
//  HomeCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class HomeCommandSpec: QuickSpec {
    override func spec() {
        describe("home command") {
            it("opens app on MAS Preview") {
                let cmd = HomeCommand()
                let result = cmd.run(HomeCommand.Options(appId: ""))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
