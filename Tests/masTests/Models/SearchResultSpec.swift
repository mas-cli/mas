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

public class SearchResultSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("search result") {
            it("can parse things") {
                expect(
                    try JSONDecoder()
                        .decode(SearchResult.self, from: Data(from: "search/things-that-go-bump.json"))
                        .bundleId
                )
                    == "uikitformac.com.tinybop.thingamabops"
            }
        }
    }
}
