//
// SignInSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Nimble
import Quick

@testable private import mas

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
