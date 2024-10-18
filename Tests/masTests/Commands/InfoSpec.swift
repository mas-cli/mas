//
//  InfoSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class InfoSpec: QuickSpec {
    override public func spec() {
        let storeSearch = StoreSearchMock()

        beforeSuite {
            Mas.initialize()
        }
        describe("Info command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try Mas.Info.parse(["--", "-999"]).run(storeSearch: storeSearch)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try Mas.Info.parse(["999"]).run(storeSearch: storeSearch)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("displays app details") {
                let mockResult = SearchResult(
                    currentVersionReleaseDate: "2019-01-07T18:53:13Z",
                    fileSizeBytes: "1024",
                    minimumOsVersion: "10.14",
                    price: 2.0,
                    sellerName: "Awesome Dev",
                    trackId: 1111,
                    trackName: "Awesome App",
                    trackViewUrl: "https://awesome.app",
                    version: "1.0"
                )
                storeSearch.apps[mockResult.trackId] = mockResult
                expect {
                    try captureStream(stdout) {
                        try Mas.Info.parse([String(mockResult.trackId)]).run(storeSearch: storeSearch)
                    }
                }
                    == """
                    Awesome App 1.0 [2.0]
                    By: Awesome Dev
                    Released: 2019-01-07
                    Minimum OS: 10.14
                    Size: 1 KB
                    From: https://awesome.app

                    """
            }
        }
    }
}
