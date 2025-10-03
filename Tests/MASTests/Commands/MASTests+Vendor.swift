//
// MASTests+Vendor.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test
	static func cannotFindVendorOfUnknownAppID() async {
		#expect(
			await consequencesOf(try await MAS.Vendor.parse(["999"]).run(searcher: MockAppStoreSearcher()))
			== Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
		) // swiftformat:disable:previous indent
	}
}
