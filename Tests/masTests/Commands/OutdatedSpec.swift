//
// OutdatedSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
import Quick

final class OutdatedSpec: AsyncSpec {
	override static func spec() {
		describe("outdated command") {
			it("outputs apps with pending updates") {
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
						try await MAS.Outdated.parse([]).run(
							installedApps: [
								InstalledApp(
									id: mockSearchResult.trackId,
									bundleID: "au.id.haroldchu.mac.Bandwidth",
									name: mockSearchResult.trackName,
									path: "/Applications/Bandwidth+.app",
									version: "1.27"
								),
							],
							searcher: MockAppStoreSearcher([mockSearchResult.trackId: mockSearchResult])
						)
					)
				)
					== UnvaluedConsequences(nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n")
			}
		}
	}
}
