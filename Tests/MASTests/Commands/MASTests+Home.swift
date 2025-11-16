//
// MASTests+Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func cannotFindAppHomeForUnknownAppID() async {
		let actual = await consequencesOf(
			await MAS.main(try MAS.Home.parse(["999"])) { await $0.run(searcher: MockAppStoreSearcher()) }
		)
		let expected = Consequences(nil, "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
		#expect(actual == expected)
	}
}
