//
// AccountSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class AccountSpec: AsyncSpec {
	override static func spec() {
		describe("account command") {
			it("displays not supported warning") {
				await expecta(await consequencesOf(try await MAS.Account.parse([]).run()))
					== UnvaluedConsequences(MASError.notSupported, "", "")
			}
		}
	}
}
