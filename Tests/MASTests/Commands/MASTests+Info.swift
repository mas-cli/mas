//
// MASTests+Info.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func cannotFindAppInfoForUnknownAppID() async {
		#expect(
			await consequencesOf(try await MAS.Info.parse(["999"]).run(searcher: MockAppStoreSearcher()))
			== Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for ADAM ID 999\n")
		) // swiftformat:disable:previous indent
	}

	@Test
	static func outputsAppInfo() async {
		let result = SearchResult(
			adamID: 1111,
			appStoreURL: "https://awesome.app",
			fileSizeBytes: "1024",
			formattedPrice: "$2.00",
			minimumOSVersion: "10.14",
			name: "Awesome App",
			releaseDate: "2019-01-07T18:53:13Z",
			vendorName: "Awesome Dev",
			version: "1.0"
		)
		#expect(
			await consequencesOf(
				try await MAS.Info.parse([String(result.adamID)]).run(
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
}
