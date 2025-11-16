//
// MASTests+Seller.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func cannotFindSellerURLForUnknownAppID() async {
		let actual = await consequencesOf(
			await MAS.main(try MAS.Seller.parse(["999"])) { await $0.run(searchResults: []) }
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
