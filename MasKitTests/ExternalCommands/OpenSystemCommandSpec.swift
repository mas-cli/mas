//
//  OpenSystemCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2/24/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class OpenSystemCommandSpec: QuickSpec {
    override func spec() {
        describe("open system command") {

            context("binary path") {
                it("defaults to the macOS open command") {
                    let cmd = OpenSystemCommand()
                    expect(cmd.binaryPath) == "/usr/bin/open"
                }
                it("can be overridden") {
                    let cmd = OpenSystemCommand(binaryPath: "/dev/null")
                    expect(cmd.binaryPath) == "/dev/null"
                }
            }
        }
    }
}
