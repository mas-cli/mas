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
						// swiftformat:disable indent
						try JSONDecoder().decode(SearchResult.self, from: Data(fromResource: "search/things-that-go-bump.json"))
						.trackId
						// swiftformat:enable indent
					)
				)
					== ValuedConsequences(1_472_954_003, nil, "", "")
			}
		}
	}
}
