//
// MASTests+ITunesSearchAppCatalog.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func iTunesSearchesForSlack() async {
		let actual = await consequencesOf(
			try await ITunesSearchAppCatalog(networkSession: try MockNetworkSession(responseResource: "slack"))
			.search(for: "slack") // swiftformat:disable:this indent
		)
		#expect(actual.value?.count == 39 && actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
	}

	@Test
	func looksUpSlack() async {
		let adamID = 803_453_959 as ADAMID
		let actual = await consequencesOf(
			try await ITunesSearchAppCatalog(networkSession: try MockNetworkSession(responseResource: "slack-lookup"))
			.lookup(appID: .adamID(adamID)) // swiftformat:disable:this indent
		)
		#expect(actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
		guard let catalogApp = actual.value else {
			#expect(actual.value != nil)
			return
		}

		#expect(
			catalogApp.adamID == adamID // swiftformat:disable indent
			&& catalogApp.appStorePageURL == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
			&& catalogApp.name == "Slack"
			&& catalogApp.sellerName == "Slack Technologies, Inc."
			&& catalogApp.sellerURL == "https://slack.com"
			&& catalogApp.version == "3.3.3"
		) // swiftformat:enable indent
	}
}
