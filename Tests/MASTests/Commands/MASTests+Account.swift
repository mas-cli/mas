//
// MASTests+Account.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func errorsAccountNotSupported() {
		let actual = consequencesOf(try MAS.main(try MAS.Account.parse([])))
		let expected = Consequences(nil, "", "Error: \(MASError.unsupportedCommand(MAS.Account._commandName))\n")
		#expect(actual == expected)
	}
}
