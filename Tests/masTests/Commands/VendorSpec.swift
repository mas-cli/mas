//
//  VendorSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class VendorSpec: QuickSpec {
    override public func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "https://awesome.app",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()

        beforeSuite {
            Mas.initialize()
        }
        describe("vendor command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try Mas.Vendor.parse(["--", "-999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(
                    beFailure { error in
                        expect(error) == .searchFailed
                    }
                )
            }
            it("can't find app with unknown ID") {
                expect {
                    try Mas.Vendor.parse(["999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(
                    beFailure { error in
                        expect(error) == .noSearchResultsFound
                    }
                )
            }
            it("opens vendor app page in browser") {
                storeSearch.apps[result.trackId] = result
                expect {
                    try Mas.Vendor.parse([String(result.trackId)])
                        .run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                expect(openCommand.arguments!.first!) == result.sellerUrl
            }
        }
    }
}
