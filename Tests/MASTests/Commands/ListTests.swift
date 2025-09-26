//
// ListTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func listsApps() {
	#expect(
		consequencesOf(try MAS.List.parse([]).run(installedApps: []))
		== UnvaluedConsequences( // swiftformat:disable indent
			nil,
			"",
			"""
			Warning: No installed apps found

			If this is unexpected, the following command line should fix it by
			(re)creating the Spotlight index (which might take some time):

			sudo mdutil -Eai on

			"""
		)
	) // swiftformat:enable indent
}
