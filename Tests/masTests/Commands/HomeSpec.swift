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
        let searcher = MockAppStoreSearcher()

        beforeSuite {
            MAS.initialize()
        }
        describe("home command") {
            beforeEach {
                searcher.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try MAS.Home.parse(["--", "-999"]).run(searcher: searcher)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Home.parse(["999"]).run(searcher: searcher)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("opens app on MAS Preview") {
                let mockResult = SearchResult(
                    trackId: 1111,
                    trackViewUrl: "mas preview url",
                    version: "0.0"
                )
                searcher.apps[mockResult.trackId] = mockResult
                expect {
                    try MAS.Home.parse([String(mockResult.trackId)]).run(searcher: searcher)
                }
            }
        }
    }
}
