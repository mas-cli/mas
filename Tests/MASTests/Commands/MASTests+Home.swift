//
// MASTests+Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test
	static func cannotFindAppHomeForUnknownAppID() async {
		#expect(
			await consequencesOf(try await MAS.Home.parse(["999"]).run(searcher: MockAppStoreSearcher()))
			== Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
		) // swiftformat:disable:previous indent
	}
}
