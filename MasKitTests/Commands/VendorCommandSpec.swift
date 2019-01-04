//
//  VendorCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class VendorCommandSpec: QuickSpec {
    override func spec() {
        describe("vendor command") {
            it("opens vendor app page in a browser") {
                let cmd = VendorCommand()
                let result = cmd.run(VendorCommand.Options(appId: ""))
                print(result)
//                expect(result).to(beSuccess())
            }
        }
    }
}
