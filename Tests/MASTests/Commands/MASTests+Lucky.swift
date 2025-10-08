//
// MASTests+Lucky.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func luckyInstallsAppForFirstSearchResult() async {
		#expect(
			await consequencesOf(
				try await MAS.Lucky.parse(["Slack"]).run(
					installedApps: [],
					searcher: ITunesSearchAppStoreSearcher(networkSession: try MockNetworkSession(responseResource: "slack"))
				)
			)
			== Consequences() // swiftformat:disable:this indent
		)
	}
}
