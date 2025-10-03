//
// MASTests+Account.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func errorsAccountNotSupported() async {
	#expect(
		await consequencesOf(try await MAS.Account.parse([]).run())
		== Consequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n") // swiftformat:disable:this indent
	)
}
