//
//  InfoCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class InfoCommandSpec: QuickSpec {
    public override func spec() {
        let result = SearchResult(
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
        let storeSearch = StoreSearchMock()
        let cmd = InfoCommand(storeSearch: storeSearch)
        let expectedOutput = """
            Awesome App 1.0 [2.0]
            By: Awesome Dev
            Released: 2019-01-07
            Minimum OS: 10.14
            Size: 1 KB
            From: https://awesome.app

            """

        beforeSuite {
            MasKit.initialize()
        }
        describe("Info command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                let result = cmd.run(InfoCommand.Options(appId: -999))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .searchFailed
                        })
            }
            it("can't find app with unknown ID") {
                let result = cmd.run(InfoCommand.Options(appId: 999))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .noSearchResultsFound
                        })
            }
            it("displays app details") {
                storeSearch.apps[result.trackId] = result
                let output = OutputListener()

                let result = cmd.run(InfoCommand.Options(appId: result.trackId))

                expect(result).to(beSuccess())
                expect(output.contents) == expectedOutput
            }
        }
    }
}
