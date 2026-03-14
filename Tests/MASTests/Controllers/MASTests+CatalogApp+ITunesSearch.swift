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
	func `iTunes searches for slack`() async {
		let actual = await consequencesOf(
			try await Dependencies.$current.withValue(.init { _ in (try Data(fromResource: "slack"), URLResponse()) }) {
				try await search(for: "slack").count
			},
		)
		let expected = Consequences(39)
		#expect(actual == expected)
	}

	@Test
	func `looks up slack`() async {
		let adamID = 803_453_959 as ADAMID
		let actual = await consequencesOf(
			try await Dependencies.$current.withValue(
				.init { _ in (try Data(fromResource: "slack-lookup"), URLResponse()) },
			) {
				try await lookup(appID: .adamID(adamID))
			},
		)
		#expect(actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
		guard let catalogApp = actual.value else {
			#expect(actual.value != nil)
			return
		}

		#expect(
			catalogApp.adamID == adamID // swiftformat:disable indent
			&& catalogApp.appStorePageURLString == "https://apps.apple.com/us/app/slack-for-desktop/id803453959?mt=12"
			&& catalogApp.minimumOSVersion == "10.9"
			&& catalogApp.name == "Slack"
			&& catalogApp.sellerURLString == "https://slack.com"
			&& !catalogApp.supportsMacDesktop
			&& catalogApp.version == "3.3.3",
		) // swiftformat:enable indent
	}
}
