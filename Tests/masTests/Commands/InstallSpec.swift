//
// InstallSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
import Quick

final class InstallSpec: AsyncSpec {
	override static func spec() {
		xdescribe("install command") {
			it("installs apps") {
				await expecta(
					await consequencesOf(
						try await MAS.Install.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher())
					)
				)
					== UnvaluedConsequences()
			}
		}
	}
}
