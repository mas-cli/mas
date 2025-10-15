//
// MASTests+Update.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func findsNoUpdates() async {
		let actual = await consequencesOf(try await MAS.Update.parse([]).run(installedApps: []))
		let expected = Consequences()
		#expect(actual == expected)
	}
}
