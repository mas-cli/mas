//
// MASTests+Open.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test
	static func cannotOpenUnknownAppID() async {
		#expect(
			await consequencesOf(try await MAS.Open.parse(["999"]).run(searcher: MockAppStoreSearcher()))
			== Consequences(ExitCode(1), "", "Error: \(MASError.unknownAppID(.adamID(999)))\n")
		) // swiftformat:disable:previous indent
	}
}
