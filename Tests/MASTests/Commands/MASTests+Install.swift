//
// MASTests+Install.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func doesNotInstallAppsWhenNoAppIDs() async {
		#expect(
			await consequencesOf(try await MAS.Install.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher()))
			== Consequences() // swiftformat:disable:this indent
		)
	}
}
