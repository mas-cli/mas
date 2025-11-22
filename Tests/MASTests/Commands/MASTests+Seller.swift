//
// MASTests+Seller.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func cannotFindSellerURLForUnknownAppID() async {
		let actual = await consequencesOf(
			await MAS.main(try MAS.Seller.parse(["999"])) { await $0.run(catalogApps: []) }
		)
		let expected = Consequences()
		#expect(actual == expected)
	}
}
