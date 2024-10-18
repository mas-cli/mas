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

public class OutdatedSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("outdated command") {
            it("displays apps with pending updates") {
                let mockSearchResult =
                    SearchResult(
                        bundleId: "au.id.haroldchu.mac.Bandwidth",
                        currentVersionReleaseDate: "2024-09-02T00:27:00Z",
                        fileSizeBytes: "998130",
                        minimumOsVersion: "10.13",
                        price: 0,
                        sellerName: "Harold Chu",
                        sellerUrl: "https://example.com",
                        trackId: 490_461_369,
                        trackName: "Bandwidth+",
                        trackViewUrl: "https://apps.apple.com/us/app/bandwidth/id490461369?mt=12&uo=4",
                        version: "1.28"
                    )
                let mockStoreSearch = StoreSearchMock()
                mockStoreSearch.apps[mockSearchResult.trackId] = mockSearchResult

                let mockAppLibrary = AppLibraryMock()
                mockAppLibrary.installedApps.append(
                    SoftwareProductMock(
                        appName: mockSearchResult.trackName,
                        bundleIdentifier: mockSearchResult.bundleId,
                        bundlePath: "/Applications/Bandwidth+.app",
                        bundleVersion: "1.27",
                        itemIdentifier: NSNumber(value: mockSearchResult.trackId)
                    )
                )
                expect {
                    try captureStream(stdout) {
                        try Mas.Outdated.parse([]).run(appLibrary: mockAppLibrary, storeSearch: mockStoreSearch)
                    }
                }
                    == "490461369 Bandwidth+ (1.27 -> 1.28)\n"
            }
        }
    }
}
