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
	func findsNoUpdates() async {
		let actual = await consequencesOf(await MAS.main(try MAS.Update.parse([])) { await $0.run(installedApps: []) })
		let expected = Consequences()
		#expect(actual == expected)
	}
}
