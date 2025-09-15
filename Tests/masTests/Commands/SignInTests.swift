//
// SignInTests.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test
func signsIn() {
	#expect(
		consequencesOf(try MAS.SignIn.parse(["", ""]).run())
		== UnvaluedConsequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n") // swiftformat:disable:this indent
	)
}
