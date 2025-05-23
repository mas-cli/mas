//
// OpenSpec.swift
// masTests
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
import Quick

final class OpenSpec: AsyncSpec {
	override static func spec() {
		describe("open command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Open.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(ExitCode(1), "", "Error: \(MASError.unknownAppID(999))\n")
			}
		}
	}
}
