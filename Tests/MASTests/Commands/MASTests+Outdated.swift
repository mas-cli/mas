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
				appStoreURL: "https://apps.apple.com/us/app/bandwidth/id490461369?mt=12&uo=4",
				bundleID: "au.haroldchu.mac.Bandwidth",
				fileSizeBytes: "998130",
				minimumOSVersion: "10.13",
				name: "Bandwidth+",
				releaseDate: "2024-09-02T00:27:00Z",
				vendorName: "Harold Chu",
				vendorURL: "https://example.com",
				version: "1.28"
			)
		#expect(
			await consequencesOf(
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
			== Consequences(nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n") // swiftformat:disable:this indent
		)
	}
}
