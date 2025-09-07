//
// SearchResultListSpec.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
private import Nimble
internal import Quick

final class SearchResultListSpec: QuickSpec {
	override static func spec() {
		describe("search result list") {
			it("can parse bbedit") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/bbedit.json")).resultCount
					)
				)
					== ValuedConsequences(1)
			}
			it("can parse things") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/things.json")).resultCount
					)
				)
					== ValuedConsequences(50)
			}
		}
	}
}
