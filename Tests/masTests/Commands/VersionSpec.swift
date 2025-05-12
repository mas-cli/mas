//
// VersionSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class VersionSpec: QuickSpec {
	override static func spec() {
		describe("version command") {
			it("outputs the current version") {
				expect(consequencesOf(try MAS.Version.parse([]).run())) == UnvaluedConsequences(nil, "\(Package.version)\n")
			}
		}
	}
}
