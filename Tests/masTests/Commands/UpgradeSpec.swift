//
// UpgradeSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
import Quick

final class UpgradeSpec: AsyncSpec {
	override static func spec() {
		describe("upgrade command") {
			it("finds no upgrades") {
				await expecta(
					await consequencesOf(
						try await MAS.Upgrade.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher())
					)
				)
					== UnvaluedConsequences()
			}
		}
	}
}
