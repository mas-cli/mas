//
// UpgradeSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class UpgradeSpec: AsyncSpec {
	override static func spec() {
		describe("upgrade command") {
			it("finds no upgrades") {
				await expecta(
					await consequencesOf(
						try await MAS.Upgrade.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher())
					)
				)
					== UnvaluedConsequences(nil, "", "")
			}
		}
	}
}
