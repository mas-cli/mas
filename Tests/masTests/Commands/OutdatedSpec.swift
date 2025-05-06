//
// OutdatedSpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class OutdatedSpec: AsyncSpec {
	override static func spec() {
		describe("outdated command") {
			it("displays apps with pending updates") {
				let mockSearchResult =
					SearchResult(
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

				await expecta(
					await consequencesOf(
						try await MAS.Outdated.parse([])
							.run(
								installedApps: [
									InstalledApp(
										id: mockSearchResult.trackId,
										name: mockSearchResult.trackName,
										bundleID: "au.id.haroldchu.mac.Bandwidth",
										path: "/Applications/Bandwidth+.app",
										version: "1.27"
									),
								],
								searcher: MockAppStoreSearcher([mockSearchResult.trackId: mockSearchResult])
							)
					)
				)
					== (nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n", "")
			}
		}
	}
}
