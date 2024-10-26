//
//  SearchSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class SearchSpec: QuickSpec {
    override public func spec() {
        let searcher = MockAppStoreSearcher()

        beforeSuite {
            MAS.initialize()
        }
        describe("search command") {
            beforeEach {
                searcher.reset()
            }
            it("can find slack") {
                let mockResult = SearchResult(
                    trackId: 1111,
                    trackName: "slack",
                    trackViewUrl: "mas preview url",
                    version: "0.0"
                )
                searcher.apps[mockResult.trackId] = mockResult
                expect {
                    try captureStream(stdout) {
                        try MAS.Search.parse(["slack"]).run(searcher: searcher)
                    }
                }
                    == "        1111  slack (0.0)\n"
            }
            it("fails when searching for nonexistent app") {
                expect {
                    try MAS.Search.parse(["nonexistent"]).run(searcher: searcher)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
        }
    }
}
