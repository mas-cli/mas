//
// SearchResultSpec.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
@testable private import mas
private import Nimble
import Quick

final class SearchResultSpec: QuickSpec {
	override static func spec() {
		describe("search result") {
			it("can parse things") {
				expect(
					consequencesOf(
						try JSONDecoder() // swiftformat:disable indent
						.decode(SearchResult.self, from: Data(fromResource: "search/things-that-go-bump.json"))
						.trackId // swiftformat:enable indent
					)
				)
					== ValuedConsequences(1_472_954_003)
			}
		}
	}
}
