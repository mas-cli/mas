//
// HomeSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
internal import Quick

final class HomeSpec: AsyncSpec {
	override static func spec() {
		describe("home command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Home.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for app ID 999\n")
			}
		}
	}
}
