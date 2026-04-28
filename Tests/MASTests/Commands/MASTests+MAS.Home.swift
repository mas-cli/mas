//
// MASTests+MAS.Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `cannot find app home for unknown app ID`() async {
		let actual =
			await consequencesOf(try await MAS.main(try MAS.Home.parse(["1"])) { await $0.run(catalogApps: .init()) })
		let expected = Consequences()
		#expect(actual == expected)
	}
}
