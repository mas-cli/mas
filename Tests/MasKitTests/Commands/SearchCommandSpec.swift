//
//  SearchCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class SearchCommandSpec: QuickSpec {
    override public func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackName: "slack",
            trackViewUrl: "mas preview url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()

        describe("search command") {
            beforeEach {
                storeSearch.reset()
            }
            it("can find slack") {
                storeSearch.apps[result.trackId] = result

                let search = SearchCommand(storeSearch: storeSearch)
                let searchOptions = SearchOptions(appName: "slack", price: false)
                let result = search.run(searchOptions)
                expect(result).to(beSuccess())
            }
            it("fails when searching for nonexistent app") {
                let search = SearchCommand(storeSearch: storeSearch)
                let searchOptions = SearchOptions(appName: "nonexistent", price: false)
                let result = search.run(searchOptions)
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .noSearchResultsFound
                        })
            }
        }
    }
}
