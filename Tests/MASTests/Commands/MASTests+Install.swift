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
	func doesNotInstallAppsWhenNoAppIDs() async {
		let actual = await consequencesOf(
			await MAS.main(try MAS.Install.parse([])) { command in
				await command.run(installedApps: [], searcher: MockAppStoreSearcher())
			}
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
