//
// SignInSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
import Quick

final class SignInSpec: QuickSpec {
	override static func spec() {
		describe("signin command") {
			it("signs in") {
				expect(consequencesOf(try MAS.SignIn.parse(["", ""]).run()))
					== UnvaluedConsequences(ExitCode(1), "", "Error: \(MASError.notSupported)\n")
			}
		}
	}
}
