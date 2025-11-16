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
	func luckyInstallsAppForFirstSearchResult() async {
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Lucky.parse(["Slack"])) { try await $0.run(installedApps: [], adamID: 0) }
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
