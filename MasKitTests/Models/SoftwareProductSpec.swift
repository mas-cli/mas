//
//  SoftwareProductSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2/2/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick
import Result

class SoftwareProductSpec: QuickSpec {
    override func spec() {
        describe("software product") {
            it("can be a macos installer") {
                let product = SoftwareProductMock(
                    appName: "Install macOS Mojave",
                    bundleIdentifier: "com.apple.InstallAssistant.Mojave"
                )
                expect(product.isMacosInstaller) == true
            }
            it("can be a normal app") {
                let product = SoftwareProductMock(appName: "Some Random App")
                expect(product.isMacosInstaller) == false
            }
        }
    }
}
