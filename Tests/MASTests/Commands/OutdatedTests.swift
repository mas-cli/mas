//
// OutdatedTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func outputsOutdatedApps() async {
	let result =
		SearchResult(
			bundleId: "au.haroldchu.mac.Bandwidth",
			currentVersionReleaseDate: "2024-09-02T00:27:00Z",
			fileSizeBytes: "998130",
			minimumOsVersion: "10.13",
			sellerName: "Harold Chu",
			sellerUrl: "https://example.com",
			trackId: 490_461_369,
			trackName: "Bandwidth+",
			trackViewUrl: "https://apps.apple.com/us/app/bandwidth/id490461369?mt=12&uo=4",
			version: "1.28"
		)

	#expect(
		await consequencesOf(
			try await MAS.Outdated.parse([]).run(
				installedApps: [
					InstalledApp(
						adamID: result.trackId,
						bundleID: result.bundleId,
						name: result.trackName,
						path: "/Applications/Bandwidth+.app",
						version: "1.27"
					),
				],
				searcher: MockAppStoreSearcher([.bundleID(result.bundleId): result])
			)
		)
		== Consequences(nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n") // swiftformat:disable:this indent
	)
}
