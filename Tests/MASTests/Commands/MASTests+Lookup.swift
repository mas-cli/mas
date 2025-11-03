//
// MASTests+Lookup.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func cannotLookupAppInfoForUnknownAppID() async {
		let actual = await consequencesOf(try await MAS.Lookup.parse(["999"]).run(searcher: MockAppStoreSearcher()))
		let expected = Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
		#expect(actual == expected)
	}

	@Test
	static func outputsAppInfo() async {
		let actual = await consequencesOf(
			try await MAS.Lookup.parse(["1"]).run(
				searcher: MockAppStoreSearcher(
					SearchResult(
						adamID: 1,
						appStorePageURL: "https://awesome.app",
						fileSizeBytes: "1000000",
						formattedPrice: "$2.00",
						minimumOSVersion: "10.14",
						name: "Awesome App",
						releaseDate: "2019-01-07T18:53:13Z",
						sellerName: "Awesome Dev",
						version: "1.0"
					)
				)
			)
		)
		let expected = Consequences(
			nil,
			"""
			Awesome App 1.0 [$2.00]
			By: Awesome Dev
			Released: 2019-01-07
			Minimum OS: 10.14
			Size: 1 MB
			From: https://awesome.app

			"""
		)
		#expect(actual == expected)
	}
}
