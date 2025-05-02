//
// VersionSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class VersionSpec: QuickSpec {
	override public static func spec() {
		describe("version command") {
			it("displays the current version") {
				expect(consequencesOf(try MAS.Version.parse([]).run()))
					== (nil, "\(Package.version)\n", "")
			}
		}
	}
}
