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
		let consequences = await consequencesOf(
			try await ITunesSearchAppStoreSearcher(networkSession: try MockNetworkSession(responseResource: "slack"))
			.search(for: "slack") // swiftformat:disable:this indent
		)
		#expect(
			consequences.value?.count == 39
			&& consequences.error == nil // swiftformat:disable indent
			&& consequences.stdout.isEmpty
			&& consequences.stderr.isEmpty
		) // swiftformat:enable indent
	}

	@Test
	static func looksUpSlack() async {
		let adamID = 803_453_959 as ADAMID

		let consequences = await consequencesOf(
			try await ITunesSearchAppStoreSearcher(networkSession: try MockNetworkSession(responseResource: "lookup"))
			.lookup(appID: .adamID(adamID)) // swiftformat:disable:this indent
		)
		#expect(
			consequences.error == nil
			&& consequences.stdout.isEmpty // swiftformat:disable:this indent
			&& consequences.stderr.isEmpty // swiftformat:disable:this indent
		)

		guard let result = consequences.value else {
			#expect(consequences.value != nil)
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
