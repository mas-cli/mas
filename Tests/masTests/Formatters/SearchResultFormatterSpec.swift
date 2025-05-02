//
// SearchResultFormatterSpec.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-14.
// Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class SearchResultFormatterSpec: QuickSpec {
	override public static func spec() {
		// static func reference
		let format = SearchResultFormatter.format(_:includePrice:)

		describe("search results formatter") {
			it("formats nothing as empty string") {
				expect(consequencesOf(format([], false))) == ("", nil, "", "")
			}
			it("can format a single result") {
				let result = SearchResult(
					formattedPrice: "$9.87",
					trackId: 12345,
					trackName: "Awesome App",
					version: "19.2.1"
				)
				expect(consequencesOf(format([result], false)))
					== ("       12345  Awesome App  (19.2.1)", nil, "", "")
			}
			it("can format a single result with price") {
				let result = SearchResult(
					formattedPrice: "$9.87",
					trackId: 12345,
					trackName: "Awesome App",
					version: "19.2.1"
				)
				expect(consequencesOf(format([result], true)))
					== ("       12345  Awesome App  (19.2.1)  $9.87", nil, "", "")
			}
			it("can format a two results") {
				expect(
					consequencesOf(
						format(
							[
								SearchResult(
									formattedPrice: "$9.87",
									trackId: 12345,
									trackName: "Awesome App",
									version: "19.2.1"
								),
								SearchResult(
									formattedPrice: "$0.01",
									trackId: 67890,
									trackName: "Even Better App",
									version: "1.2.0"
								),
							],
							false
						)
					)
				)
					== ("       12345  Awesome App      (19.2.1)\n       67890  Even Better App  (1.2.0)", nil, "", "")
			}
			it("can format a two results with prices") {
				expect(
					consequencesOf(
						format(
							[
								SearchResult(
									formattedPrice: "$9.87",
									trackId: 12345,
									trackName: "Awesome App",
									version: "19.2.1"
								),
								SearchResult(
									formattedPrice: "$0.01",
									trackId: 67890,
									trackName: "Even Better App",
									version: "1.2.0"
								),
							],
							true
						)
					)
				)
					== (
						"       12345  Awesome App      (19.2.1)  $9.87\n       67890  Even Better App  (1.2.0)  $0.01",
						nil,
						"",
						""
					)
			}
		}
	}
}
