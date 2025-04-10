//
//  OutdatedSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public final class OutdatedSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            MAS.initialize()
        }
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

                expect(
                    consequencesOf(
                        try MAS.Outdated.parse([])
                            .run(
                                appLibrary: MockAppLibrary(
                                    MockSoftwareProduct(
                                        appName: mockSearchResult.trackName,
                                        bundleIdentifier: "au.id.haroldchu.mac.Bandwidth",
                                        bundlePath: "/Applications/Bandwidth+.app",
                                        bundleVersion: "1.27",
                                        itemIdentifier: NSNumber(value: mockSearchResult.trackId)
                                    )
                                ),
                                searcher: MockAppStoreSearcher([mockSearchResult.trackId: mockSearchResult])
                            )
                    )
                )
                    == (nil, "490461369 Bandwidth+ (1.27 -> 1.28)\n", "")
            }
        }
    }
}
