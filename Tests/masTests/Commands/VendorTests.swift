//
// VendorTests.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test
func cannotFindVendorOfUnknownAppID() async {
	#expect(
		await consequencesOf(try await MAS.Vendor.parse(["999"]).run(searcher: MockAppStoreSearcher()))
		== UnvaluedConsequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
	) // swiftformat:disable:previous indent
}
