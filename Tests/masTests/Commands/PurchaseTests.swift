//
// PurchaseTests.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test(.disabled())
func purchasesApps() async {
	#expect(
		await consequencesOf(try await MAS.Purchase.parse(["999"]).run(installedApps: [], searcher: MockAppStoreSearcher()))
		== UnvaluedConsequences() // swiftformat:disable:this indent
	)
}
