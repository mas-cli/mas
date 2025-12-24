//
// MASTests+CatalogApp+ITunesSearch.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func iTunesSearchesForSlack() async {
		let actual = await consequencesOf(
			try await search(for: "slack") { _ in try (Data(fromResource: "slack"), URLResponse()) }.count,
		)
		let expected = Consequences(39)
		#expect(actual == expected)
	}

	@Test
	func looksUpSlack() async {
		let adamID = 803_453_959 as ADAMID
		let actual = await consequencesOf(
			try await lookup(appID: .adamID(adamID)) { _ in try (Data(fromResource: "slack-lookup"), URLResponse()) },
		)
		#expect(actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
		guard let catalogApp = actual.value else {
			#expect(actual.value != nil)
			return
		}

		#expect(
			catalogApp.adamID == adamID // swiftformat:disable indent
			&& catalogApp.appStorePageURLString == "https://apps.apple.com/us/app/slack-for-desktop/id803453959?mt=12"
			&& catalogApp.name == "Slack"
			&& catalogApp.sellerName == "Slack Technologies, Inc."
			&& catalogApp.sellerURLString == "https://slack.com"
			&& catalogApp.version == "3.3.3",
		) // swiftformat:enable indent
	}
}
