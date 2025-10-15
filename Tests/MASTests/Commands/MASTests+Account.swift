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
	static func errorsAccountNotSupported() async {
		let actual = await consequencesOf(try await MAS.Account.parse([]).run())
		let expected = Consequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n")
		#expect(actual == expected)
	}
}
