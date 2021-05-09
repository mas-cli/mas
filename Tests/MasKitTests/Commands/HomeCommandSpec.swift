//
//  HomeCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import MasKit

public class HomeCommandSpec: QuickSpec {
    override public func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "mas preview url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()
        let cmd = HomeCommand(storeSearch: storeSearch, openCommand: openCommand)

        describe("home command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                let result = cmd.run(HomeCommand.Options(appId: -999))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .searchFailed
                        })
            }
            it("can't find app with unknown ID") {
                let result = cmd.run(HomeCommand.Options(appId: 999))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .noSearchResultsFound
                        })
            }
            it("opens app on MAS Preview") {
                storeSearch.apps[result.trackId] = result

                let cmdResult = cmd.run(HomeCommand.Options(appId: result.trackId))
                expect(cmdResult).to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                expect(openCommand.arguments!.first!) == result.trackViewUrl
            }
        }
    }
}
