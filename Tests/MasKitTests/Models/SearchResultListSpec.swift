//
//  SearchResultListSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 9/2/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import MasKit

public class SearchResultListSpec: QuickSpec {
    public override func spec() {
        describe("search result list") {
            it("can parse bbedit") {
                let data = Data(from: "search/bbedit.json")
                let decoder = JSONDecoder()
                let results = try decoder.decode(SearchResultList.self, from: data)

                expect(results.resultCount) == 1
            }
            it("can parse things") {
                let data = Data(from: "search/things.json")
                let decoder = JSONDecoder()
                let results = try decoder.decode(SearchResultList.self, from: data)

                expect(results.resultCount) == 50
            }
        }
    }
}
