//
// ITunesSearchAppStoreSearcherSpec.swift
// masTests
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

@Test
func iTunesSearchesForSlack() async {
	let consequences = await consequencesOf(
		try await ITunesSearchAppStoreSearcher(networkSession: MockNetworkSession(responseResource: "search/slack.json"))
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
func looksUpSlack() async {
	let appID = 803_453_959 as AppID

	let consequences = await consequencesOf(
		try await ITunesSearchAppStoreSearcher(networkSession: MockNetworkSession(responseResource: "lookup/slack.json"))
		.lookup(appID: appID) // swiftformat:disable:this indent
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
		result.trackId == appID
		&& result.sellerName == "Slack Technologies, Inc." // swiftformat:disable indent
		&& result.sellerUrl == "https://slack.com"
		&& result.trackName == "Slack"
		&& result.trackViewUrl == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
		&& result.version == "3.3.3"
	) // swiftformat:enable indent
}
