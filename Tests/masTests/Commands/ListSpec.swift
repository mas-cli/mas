//
// ListSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-27.
// Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class ListSpec: QuickSpec {
	override public static func spec() {
		describe("list command") {
			it("lists apps") {
				expect(consequencesOf(try MAS.List.parse([]).run(installedApps: [])))
					== (
						nil,
						"",
						"""
						Error: No installed apps found

						If this is unexpected, the following command line should fix it by
						(re)creating the Spotlight index (which might take some time):

						sudo mdutil -Eai on

						"""
					)
			}
		}
	}
}
