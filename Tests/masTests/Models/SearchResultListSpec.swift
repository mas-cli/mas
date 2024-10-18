//
//  SearchResultListSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 9/2/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class SearchResultListSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("search result list") {
            it("can parse bbedit") {
                expect(
                    try JSONDecoder().decode(SearchResultList.self, from: Data(from: "search/bbedit.json")).resultCount
                )
                    == 1
            }
            it("can parse things") {
                expect(
                    try JSONDecoder().decode(SearchResultList.self, from: Data(from: "search/things.json")).resultCount
                )
                    == 50
            }
        }
    }
}
