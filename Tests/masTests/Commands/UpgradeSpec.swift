//
// UpgradeSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
internal import Quick

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
