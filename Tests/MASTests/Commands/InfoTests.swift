//
// InfoTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func cannotFindAppInfoForUnknownAppID() async {
	#expect(
		await consequencesOf(try await MAS.Info.parse(["999"]).run(searcher: MockAppStoreSearcher()))
		== Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
	) // swiftformat:disable:previous indent
}

@Test
func outputsAppInfo() async {
	let result = SearchResult(
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
	#expect(
		await consequencesOf(
			try await MAS.Info.parse([String(result.trackId)]).run(
				searcher: MockAppStoreSearcher([.adamID(result.adamID): result])
			)
		)
		== Consequences( // swiftformat:disable indent
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
	) // swiftformat:enable indent
}
