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
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try Mas.Vendor.parse(["999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("opens vendor app page in browser") {
                let mockResult = SearchResult(
                    sellerUrl: "https://awesome.app",
                    trackId: 1111,
                    trackViewUrl: "https://apps.apple.com/us/app/awesome/id1111?mt=12&uo=4",
                    version: "0.0"
                )
                storeSearch.apps[mockResult.trackId] = mockResult
                expect {
                    try Mas.Vendor.parse([String(mockResult.trackId)])
                        .run(storeSearch: storeSearch, openCommand: openCommand)
                    return openCommand.arguments
                }
                    == [mockResult.sellerUrl]
            }
        }
    }
}
