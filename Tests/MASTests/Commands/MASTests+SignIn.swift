//
// MASTests+SignIn.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func signsIn() {
		let actual = consequencesOf(try MAS.main(try MAS.SignIn.parse(["", ""])))
		let expected = Consequences(nil, "", "Error: \(MASError.notSupported)\n")
		#expect(actual == expected)
	}
}
