//
// MASTests+Get.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	func getsApps() async {
		let actual = await consequencesOf(
			await MAS.main(try MAS.Get.parse(["999"])) { await $0.run(installedApps: [], adamIDs: []) }
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
