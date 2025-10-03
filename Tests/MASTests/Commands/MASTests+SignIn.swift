//
// MASTests+SignIn.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test
	static func signsIn() {
		#expect(
			consequencesOf(try MAS.SignIn.parse(["", ""]).run())
			== Consequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n") // swiftformat:disable:this indent
		)
	}
}
