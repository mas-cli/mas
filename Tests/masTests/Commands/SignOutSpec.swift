//
// SignOutSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class SignOutSpec: QuickSpec {
	override static func spec() {
		describe("signout command") {
			it("signs out") {
				expect(consequencesOf(try MAS.SignOut.parse([]).run()))
					== (nil, "", "")
			}
		}
	}
}
