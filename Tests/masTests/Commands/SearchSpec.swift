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

public final class SearchSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("search command") {
            it("can find slack") {
                let mockResult = SearchResult(
                    trackId: 1111,
                    trackName: "slack",
                    trackViewUrl: "mas preview url",
                    version: "0.0"
                )
                expect(
                    consequencesOf(
                        try MAS.Search.parse(["slack"])
                            .run(searcher: MockAppStoreSearcher([mockResult.trackId: mockResult]))
                    )
                )
                    == (nil, "        1111  slack  (0.0)\n", "")
            }
            it("fails when searching for nonexistent app") {
                expect(consequencesOf(try MAS.Search.parse(["nonexistent"]).run(searcher: MockAppStoreSearcher())))
                    == (MASError.noSearchResultsFound, "", "")
            }
        }
    }
}
