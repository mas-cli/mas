//
// MASTests+Account.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func errorsAccountNotSupported() async {
		let actual = await consequencesOf(try await MAS.main(try MAS.Account.parse([])))
		let expected = Consequences(nil, "", "Error: \(MASError.notSupported)\n")
		#expect(actual == expected)
	}
}
