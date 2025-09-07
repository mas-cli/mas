//
// InfoSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
internal import Quick

final class InfoSpec: AsyncSpec {
	override static func spec() {
		describe("Info command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Info.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for app ID 999\n")
			}
			it("outputs app details") {
				let mockResult = SearchResult(
					currentVersionReleaseDate: "2019-01-07T18:53:13Z",
					fileSizeBytes: "1024",
					formattedPrice: "$2.00",
					minimumOsVersion: "10.14",
					sellerName: "Awesome Dev",
					trackId: 1111,
					trackName: "Awesome App",
					trackViewUrl: "https://awesome.app",
					version: "1.0"
				)
				await expecta(
					await consequencesOf(
						try await MAS.Info.parse([String(mockResult.trackId)]).run(
							searcher: MockAppStoreSearcher([mockResult.trackId: mockResult])
						)
					)
				)
					== UnvaluedConsequences(
						nil,
						"""
						Awesome App 1.0 [$2.00]
						By: Awesome Dev
						Released: 2019-01-07
						Minimum OS: 10.14
						Size: 1 KB
						From: https://awesome.app

						"""
					)
			}
		}
	}
}
