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
        let searcher = MockAppStoreSearcher()
        let openCommand = OpenSystemCommandMock()

        beforeSuite {
            MAS.initialize()
        }
        describe("vendor command") {
            beforeEach {
                searcher.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try MAS.Vendor.parse(["--", "-999"]).run(searcher: searcher, openCommand: openCommand)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Vendor.parse(["999"]).run(searcher: searcher, openCommand: openCommand)
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
                searcher.apps[mockResult.trackId] = mockResult
                expect {
                    try MAS.Vendor.parse([String(mockResult.trackId)])
                        .run(searcher: searcher, openCommand: openCommand)
                    return openCommand.arguments
                }
                    == [mockResult.sellerUrl]
            }
        }
    }
}
