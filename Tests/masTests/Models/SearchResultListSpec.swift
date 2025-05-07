//
// SearchResultListSpec.swift
// masTests
//
// Created by Ben Chatelain on 2020-09-02.
// Copyright © 2020 mas-cli. All rights reserved.
//

import Foundation
private import Nimble
import Quick

@testable private import mas

final class SearchResultListSpec: QuickSpec {
	override static func spec() {
		describe("search result list") {
			it("can parse bbedit") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/bbedit.json")).resultCount
					)
				)
					== ValuedConsequences(1, nil, "", "")
			}
			it("can parse things") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/things.json")).resultCount
					)
				)
					== ValuedConsequences(50, nil, "", "")
			}
		}
	}
}
