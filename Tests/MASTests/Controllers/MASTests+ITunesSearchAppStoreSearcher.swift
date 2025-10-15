//
// MASTests+ITunesSearchAppStoreSearcher.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func iTunesSearchesForSlack() async {
		let actual = await consequencesOf(
			try await ITunesSearchAppStoreSearcher(networkSession: try MockNetworkSession(responseResource: "slack"))
			.search(for: "slack") // swiftformat:disable:this indent
		)
		#expect(actual.value?.count == 39 && actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
	}

	@Test
	static func looksUpSlack() async {
		let adamID = 803_453_959 as ADAMID
		let actual = await consequencesOf(
			try await ITunesSearchAppStoreSearcher(networkSession: try MockNetworkSession(responseResource: "lookup"))
			.lookup(appID: .adamID(adamID)) // swiftformat:disable:this indent
		)
		#expect(actual.error == nil && actual.stdout.isEmpty && actual.stderr.isEmpty)
		guard let result = actual.value else {
			#expect(actual.value != nil)
			return
		}

		#expect(
			result.adamID == adamID
			&& result.vendorName == "Slack Technologies, Inc." // swiftformat:disable indent
			&& result.vendorURL == "https://slack.com"
			&& result.name == "Slack"
			&& result.appStoreURL == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
			&& result.version == "3.3.3"
		) // swiftformat:enable indent
	}
}
