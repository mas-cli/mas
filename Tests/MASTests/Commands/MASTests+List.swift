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
		let actual = consequencesOf(try MAS.main(try MAS.List.parse([])) { $0.run(installedApps: []) })
		let expected = Consequences(
			nil,
			"",
			"""
			Warning: No installed apps found

			If this is unexpected, any of the following command lines should fix things by reindexing apps in the Spotlight\
			 MDS index (which might take some time):

			# Individual apps (if you know exactly what apps were incorrectly omitted):
			mdimport /Applications/Example.app

			# All apps (<LargeAppVolume> is the volume optionally selected for large apps):
			mdimport /Applications /Volumes/<LargeAppVolume>/Applications

			# All file system volumes (if neither aforementioned command solved the issue):
			sudo mdutil -Eai on

			""",
		)
		#expect(actual == expected)
	}
}
