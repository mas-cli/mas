//
//  SearchResultSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 9/2/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public final class SearchResultSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("search result") {
            it("can parse things") {
                expect(
                    consequencesOf(
                        try JSONDecoder()
                            .decode(SearchResult.self, from: Data(from: "search/things-that-go-bump.json"))
                            .trackId
                    )
                )
                    == (1_472_954_003, nil, "", "")
            }
        }
    }
}
