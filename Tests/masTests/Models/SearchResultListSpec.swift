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

public final class SearchResultListSpec: QuickSpec {
	override public static func spec() {
		describe("search result list") {
			it("can parse bbedit") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/bbedit.json"))
							.resultCount
					)
				)
					== (1, nil, "", "")
			}
			it("can parse things") {
				expect(
					consequencesOf(
						try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/things.json"))
							.resultCount
					)
				)
					== (50, nil, "", "")
			}
		}
	}
}
