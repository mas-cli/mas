//
// UpgradeSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test
func findsNoUpgrades() async {
	#expect(
		await consequencesOf(try await MAS.Upgrade.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher()))
		== UnvaluedConsequences() // swiftformat:disable:this indent
	)
}
