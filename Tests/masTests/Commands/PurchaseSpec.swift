//
// PurchaseSpec.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class PurchaseSpec: AsyncSpec {
	override static func spec() {
		xdescribe("purchase command") {
			it("purchases apps") {
				await expecta(
					await consequencesOf(
						try await MAS.Purchase.parse(["999"]).run(installedApps: [], searcher: MockAppStoreSearcher())
					)
				)
					== UnvaluedConsequences()
			}
		}
	}
}
