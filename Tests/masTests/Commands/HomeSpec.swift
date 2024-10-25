//
//  HomeSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class HomeSpec: QuickSpec {
    override public func spec() {
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()

        beforeSuite {
            MAS.initialize()
        }
        describe("home command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try MAS.Home.parse(["--", "-999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Home.parse(["999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("opens app on MAS Preview") {
                let mockResult = SearchResult(
                    trackId: 1111,
                    trackViewUrl: "mas preview url",
                    version: "0.0"
                )
                storeSearch.apps[mockResult.trackId] = mockResult
                expect {
                    try MAS.Home.parse([String(mockResult.trackId)])
                        .run(storeSearch: storeSearch, openCommand: openCommand)
                    return openCommand.arguments
                }
                    == [mockResult.trackViewUrl]
            }
        }
    }
}
