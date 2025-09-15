//
// LuckyTests.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test(.disabled())
func luckyInstallsAppForFirstSearchResult() async {
	#expect(
		await consequencesOf(
			try await MAS.Lucky.parse(["Slack"]).run(
				installedApps: [],
				searcher: ITunesSearchAppStoreSearcher(
					networkSession: MockNetworkSession(responseResource: "search/slack.json")
				)
			)
		)
		== UnvaluedConsequences() // swiftformat:disable:this indent
	)
}
