//
//  SearchResultListSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 9/2/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

@testable import MasKit
import Quick
import Nimble

class SearchResultListSpec: QuickSpec {
    override func spec() {
        describe("search result list") {
            it("can parse bbedit") {
                let data = Data(from: "search/bbedit.json")
                let decoder = JSONDecoder()
                let results = try! decoder.decode(SearchResultList.self, from: data)

                expect(results.resultCount) == 1
            }
        }
    }
}
