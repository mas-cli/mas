//
// ListSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Nimble
import Quick

@testable private import mas

final class ListSpec: QuickSpec {
	override static func spec() {
		describe("list command") {
			it("lists apps") {
				expect(consequencesOf(try MAS.List.parse([]).run(installedApps: [])))
					== UnvaluedConsequences(
						ExitCode(1),
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
