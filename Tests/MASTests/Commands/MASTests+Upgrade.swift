//
// MASTests+Upgrade.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func findsNoUpgrades() async {
		#expect(
			await consequencesOf(try await MAS.Upgrade.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher()))
			== Consequences() // swiftformat:disable:this indent
		)
	}
}
