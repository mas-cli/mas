//
// AccountSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Nimble
import Quick

@testable private import mas

final class AccountSpec: AsyncSpec {
	override static func spec() {
		describe("account command") {
			it("outputs not supported warning") {
				await expecta(await consequencesOf(try await MAS.Account.parse([]).run()))
					== UnvaluedConsequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n")
			}
		}
	}
}
