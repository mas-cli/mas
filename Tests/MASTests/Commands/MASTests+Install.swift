//
// MASTests+Install.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func doesNotInstallAppsWhenNoAppIDs() async {
		let actual =
			await consequencesOf(try await MAS.Install.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher()))
		let expected = Consequences()
		#expect(actual == expected)
	}
}
