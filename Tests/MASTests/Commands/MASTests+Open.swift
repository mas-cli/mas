//
// MASTests+Open.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func cannotOpenUnknownAppID() async {
		let adamID = 999 as ADAMID
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Open.parse([String(adamID)])) { try await $0.run(searcher: MockAppStoreSearcher()) }
		)
		let expected = Consequences(MASError.unknownAppID(.adamID(adamID)))
		#expect(actual == expected)
	}
}
