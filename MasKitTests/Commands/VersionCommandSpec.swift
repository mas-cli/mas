//
//  VersionCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class VersionCommandSpec: QuickSpec {
    override func spec() {
        describe("version command") {
            it("displays the current version") {
                let cmd = VersionCommand()
                let result = cmd.run(VersionCommand.Options())
                print(result)
                //                expect(result).to(beSuccess())
            }
        }
    }
}
