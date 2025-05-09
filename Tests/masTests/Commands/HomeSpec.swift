//
// HomeSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-29.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class HomeSpec: AsyncSpec {
	override static func spec() {
		describe("home command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Home.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(nil, "", "Error: No apps found in the Mac App Store for app ID 999\n")
			}
		}
	}
}
