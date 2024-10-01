//
//  SearchSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class SearchSpec: QuickSpec {
    override public func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackName: "slack",
            trackViewUrl: "mas preview url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()

        beforeSuite {
            Mas.initialize()
        }
        describe("search command") {
            beforeEach {
                storeSearch.reset()
            }
            it("can find slack") {
                storeSearch.apps[result.trackId] = result
                expect {
                    try Mas.Search.parse(["slack"]).run(storeSearch: storeSearch)
                }
                .to(beSuccess())
            }
            it("fails when searching for nonexistent app") {
                expect {
                    try Mas.Search.parse(["nonexistent"]).run(storeSearch: storeSearch)
                }
                .to(
                    beFailure { error in
                        expect(error) == .noSearchResultsFound
                    }
                )
            }
        }
    }
}
