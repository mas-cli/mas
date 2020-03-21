//
//  VendorCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick

class VendorCommandSpec: QuickSpec {
    override func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "https://awesome.app",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()
        let cmd = VendorCommand(storeSearch: storeSearch, openCommand: openCommand)

        describe("vendor command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                let result = cmd.run(VendorCommand.Options(appId: -999))
                expect(result).to(beFailure { error in
                    expect(error) == .searchFailed
                })
            }
            it("can't find app with unknown ID") {
                let result = cmd.run(VendorCommand.Options(appId: 999))
                expect(result).to(beFailure { error in
                    expect(error) == .noSearchResultsFound
                })
            }
            it("opens vendor app page in browser") {
                storeSearch.apps[result.trackId] = result

                let cmdResult = cmd.run(VendorCommand.Options(appId: result.trackId))
                expect(cmdResult).to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                expect(openCommand.arguments!.first!) == result.sellerUrl
            }
        }
    }
}
