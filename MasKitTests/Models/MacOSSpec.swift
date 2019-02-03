//
//  MacOSSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2/2/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick
import Result

class MacOSSpec: QuickSpec {
    override func spec() {
        describe("macos") {
            context("mojave") {
                let macos = MacOS.mojave
                it("has an identifier") {
                    expect(macos.identifier) == 1_398_502_828
                }
                it("has a name") {
                    expect(macos.name) == "Mojave"
                }
                it("has a token") {
                    expect(macos.token) == "macos-mojave"
                }
                it("has one or more altnernate tokens") {
                    expect(macos.altTokens).to(contain("mojave"))
                }
                it("has a version") {
                    expect(macos.version) == "10.14"
                }
                it("has a url") {
                    expect(macos.url) == "https://itunes.apple.com/us/app/macos-mojave/id1398502828?mt=12"
                }
                it("has a description") {
                    expect(macos.description) ==
                    "Mojave 10.14 (1398502828) https://itunes.apple.com/us/app/macos-mojave/id1398502828?mt=12"
                }
            }
            it("can be found by token") {
                let os = MacOS.os(withToken: "mojave")
                expect(os) == .mojave
            }
        }
    }
}
