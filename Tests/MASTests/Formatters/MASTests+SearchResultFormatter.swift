//
// MASTests+SearchResultFormatter.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

private let format = SearchResultFormatter.format(_:includePrice:)

extension MASTests {
	@Test
	static func formatsEmptySearchResultsAsEmptyString() {
		#expect(consequencesOf(format([], false)) == Consequences(""))
	}

	@Test
	static func formatsSingleResult() {
		#expect(
			consequencesOf(
				format([SearchResult(adamID: 12345, formattedPrice: "$9.87", name: "Awesome App", version: "19.2.1")], false)
			)
			== Consequences("12345  Awesome App  (19.2.1)") // swiftformat:disable:this indent
		)
	}

	@Test
	static func formatsSingleResultWithPrice() {
		#expect(
			consequencesOf(
				format([SearchResult(adamID: 12345, formattedPrice: "$9.87", name: "Awesome App", version: "19.2.1")], true)
			)
			== Consequences("12345  Awesome App  (19.2.1)  $9.87") // swiftformat:disable:this indent
		)
	}

	@Test
	static func formatsTwoResults() {
		#expect(
			consequencesOf(
				format(
					[
						SearchResult(adamID: 12345, formattedPrice: "$9.87", name: "Awesome App", version: "19.2.1"),
						SearchResult(adamID: 67890, formattedPrice: "$0.01", name: "Even Better App", version: "1.2.0"),
					],
					false
				)
			) // swiftformat:disable:next indent
			== Consequences("12345  Awesome App      (19.2.1)\n67890  Even Better App  (1.2.0)")
		)
	}

	@Test
	static func formatsTwoResultsWithPrices() {
		#expect(
			consequencesOf(
				format(
					[
						SearchResult(adamID: 12345, formattedPrice: "$9.87", name: "Awesome App", version: "19.2.1"),
						SearchResult(adamID: 67890, formattedPrice: "$0.01", name: "Even Better App", version: "1.2.0"),
					],
					true
				)
			) // swiftformat:disable:next indent
			== Consequences("12345  Awesome App      (19.2.1)  $9.87\n67890  Even Better App  (1.2.0)  $0.01")
		)
	}
}
