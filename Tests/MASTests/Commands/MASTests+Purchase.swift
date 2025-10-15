//
// MASTests+Purchase.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func purchasesApps() async {
		let actual = await consequencesOf(
			try await MAS.Purchase.parse(["999"]).run(installedApps: [], searcher: MockAppStoreSearcher())
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
