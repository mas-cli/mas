//
//  OpenCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class OpenCommandSpec: QuickSpec {
    override func spec() {
        describe("Open command") {
            it("opens app in MAS app") {
                let cmd = OpenCommand()
                let result = cmd.run(OpenCommand.Options(appId: ""))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
