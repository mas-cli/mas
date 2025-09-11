//
// SearchSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
internal import Quick

final class SearchSpec: AsyncSpec {
	override static func spec() {
		describe("search command") {
			it("can find slack") {
				let mockResult = SearchResult(
					trackId: 1111,
					trackName: "slack",
					trackViewUrl: "mas preview url",
					version: "0.0"
				)
				await expecta(
					await consequencesOf(
						try await MAS.Search.parse(["slack"]).run(searcher: MockAppStoreSearcher([mockResult.trackId: mockResult]))
					)
				)
					== UnvaluedConsequences(nil, "        1111  slack  (0.0)\n")
			}
			it("fails when searching for nonexistent app") {
				let searchTerm = "nonexistent"
				await expecta(
					await consequencesOf(
						try await MAS.Search.parse([searchTerm]).run(searcher: MockAppStoreSearcher())
					)
				)
					== UnvaluedConsequences(
						ExitCode(1),
						"",
						"Error: No apps found in the Mac App Store for search term: \(searchTerm)\n"
					)
			}
		}
	}
}
