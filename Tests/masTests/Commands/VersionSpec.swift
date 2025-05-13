//
// VersionSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
import Quick

final class VersionSpec: QuickSpec {
	override static func spec() {
		describe("version command") {
			it("outputs the current version") {
				expect(consequencesOf(try MAS.Version.parse([]).run())) == UnvaluedConsequences(nil, "\(Package.version)\n")
			}
		}
	}
}
