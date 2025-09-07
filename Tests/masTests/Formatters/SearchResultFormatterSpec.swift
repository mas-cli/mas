//
// SearchResultFormatterSpec.swift
// masTests
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
internal import Quick

final class SearchResultFormatterSpec: QuickSpec {
	override static func spec() {
		// Static func reference
		let format = SearchResultFormatter.format(_:includePrice:)

		describe("search results formatter") {
			it("formats nothing as empty string") {
				expect(consequencesOf(format([], false))) == ValuedConsequences("")
			}
			it("can format a single result") {
				let result = SearchResult(
					formattedPrice: "$9.87",
					trackId: 12345,
					trackName: "Awesome App",
					version: "19.2.1"
				)
				expect(consequencesOf(format([result], false))) == ValuedConsequences("       12345  Awesome App  (19.2.1)")
			}
			it("can format a single result with price") {
				let result = SearchResult(
					formattedPrice: "$9.87",
					trackId: 12345,
					trackName: "Awesome App",
					version: "19.2.1"
				)
				expect(consequencesOf(format([result], true)))
					== ValuedConsequences("       12345  Awesome App  (19.2.1)  $9.87")
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
					== ValuedConsequences("       12345  Awesome App      (19.2.1)\n       67890  Even Better App  (1.2.0)")
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
					== ValuedConsequences(
						"       12345  Awesome App      (19.2.1)  $9.87\n       67890  Even Better App  (1.2.0)  $0.01"
					)
			}
		}
	}
}
