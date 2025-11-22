//
// MASTests+List.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func listsApps() {
		let actual = consequencesOf(MAS.main(try MAS.List.parse([])) { $0.run(installedApps: []) })
		let expected = Consequences(
			nil,
			"",
			"""
			Warning: No installed apps found

			If this is unexpected, the following command line should fix it by
			(re)creating the Spotlight index (which might take some time):

			sudo mdutil -Eai on

			"""
		)
		#expect(actual == expected)
	}
}
