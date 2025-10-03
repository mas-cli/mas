//
// SignInTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func signsIn() {
	#expect(
		consequencesOf(try MAS.SignIn.parse(["", ""]).run())
		== Consequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n") // swiftformat:disable:this indent
	)
}
