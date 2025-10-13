//
// MASTests+Outdated.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	static func outputsOutdatedApps() async {
		let result =
			SearchResult(
				adamID: 490_461_369,
				appStorePageURL: "https://apps.apple.com/us/app/bandwidth/id490461369?mt=12&uo=4",
				bundleID: "au.haroldchu.mac.Bandwidth",
				fileSizeBytes: "998130",
				minimumOSVersion: "10.13",
				name: "Bandwidth+",
				releaseDate: "2024-09-02T00:27:00Z",
				sellerName: "Harold Chu",
				sellerURL: "https://example.com",
				version: "1.28"
			)
		let actual = await consequencesOf(
			try await MAS.Outdated.parse([]).run(
				installedApps: [
					InstalledApp(
						adamID: result.adamID,
						bundleID: result.bundleID,
						name: result.name,
						path: "/Applications/Bandwidth+.app",
						version: "1.27"
					),
				]
			)
		)
		let expected = Consequences(nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n")
		#expect(actual == expected)
	}
}
