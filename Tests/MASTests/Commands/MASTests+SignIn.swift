//
// MASTests+SignIn.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func signsIn() {
		let actual = consequencesOf(try MAS.SignIn.parse(["", ""]).run())
		let expected = Consequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n")
		#expect(actual == expected)
	}
}
