//
//  SearchResultFormatterSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/14/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Nimble
import Quick
import Result

class SearchResultsFormatterSpec: QuickSpec {
    override func spec() {
        // static func reference
        let format = SearchResultFormatter.format(results:includePrice:)
        var results: [SearchResult] = []

        describe("search results formatter") {
            beforeEach {
                results = []
            }
            it("formats nothing as empty string") {
                let output = format(results, false)
                expect(output) == ""
            }
            it("can format a single result") {
                results = [SearchResult(
                    price: 9.87,
                    trackId: 12345,
                    trackName: "Awesome App",
                    version: "19.2.1"
                )]
                let output = format(results, false)
                expect(output) == "       12345  Awesome App (19.2.1)"
            }
            it("can format a single result with price") {
                results = [SearchResult(
                    price: 9.87,
                    trackId: 12345,
                    trackName: "Awesome App",
                    version: "19.2.1"
                )]
                let output = format(results, true)
                expect(output) == "       12345  Awesome App  $ 9.87  (19.2.1)"
            }
            it("can format a two results") {
                results = [
                    SearchResult(
                        price: 9.87,
                        trackId: 12345,
                        trackName: "Awesome App",
                        version: "19.2.1"
                    ),
                    SearchResult(
                        price: 0.01,
                        trackId: 67890,
                        trackName: "Even Better App",
                        version: "1.2.0"
                    )
                ]
                let output = format(results, false)
                expect(output) ==
                    "       12345  Awesome App     (19.2.1)\n       67890  Even Better App (1.2.0)"
            }
            it("can format a two results with prices") {
                results = [
                    SearchResult(
                        price: 9.87,
                        trackId: 12345,
                        trackName: "Awesome App",
                        version: "19.2.1"
                    ),
                    SearchResult(
                        price: 0.01,
                        trackId: 67890,
                        trackName: "Even Better App",
                        version: "1.2.0"
                    )
                ]
                let output = format(results, true)
                expect(output) ==
                    "       12345  Awesome App      $ 9.87  (19.2.1)\n       67890  Even Better App  $ 0.01  (1.2.0)"
            }
        }
    }
}
