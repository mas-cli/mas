//
// SearchResultSpec.swift
// masTests
//
// Created by Ben Chatelain on 2020-09-02.
// Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
private import Nimble
import Quick

@testable private import mas

final class SearchResultSpec: QuickSpec {
	override static func spec() {
		describe("search result") {
			it("can parse things") {
				expect(
					consequencesOf(
						try JSONDecoder()
							.decode(SearchResult.self, from: Data(fromResource: "search/things-that-go-bump.json"))
							.trackId
					)
				)
					== (1_472_954_003, nil, "", "")
			}
		}
	}
}
