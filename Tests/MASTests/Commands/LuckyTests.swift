//
// LuckyTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test(.disabled())
func luckyInstallsAppForFirstSearchResult() async {
	#expect(
		await consequencesOf(
			try await MAS.Lucky.parse(["Slack"]).run(
				installedApps: [],
				searcher: ITunesSearchAppStoreSearcher(
					networkSession: try MockNetworkSession(responseResource: "search/slack.json")
				)
			)
		)
		== UnvaluedConsequences() // swiftformat:disable:this indent
	)
}
