//
// SignOutSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
internal import Quick

final class SignOutSpec: QuickSpec {
	override static func spec() {
		describe("signout command") {
			it("signs out") {
				expect(consequencesOf(try MAS.SignOut.parse([]).run())) == UnvaluedConsequences()
			}
		}
	}
}
