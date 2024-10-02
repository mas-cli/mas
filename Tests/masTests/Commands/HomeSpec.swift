//
//  HomeSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class HomeSpec: QuickSpec {
    override public static func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "mas preview url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()

        beforeSuite {
            Mas.initialize()
        }
        describe("home command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try Mas.Home.parse(["--", "-999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try Mas.Home.parse(["999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("opens app on MAS Preview") {
                storeSearch.apps[result.trackId] = result
                expect {
                    try Mas.Home.parse([String(result.trackId)]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .toNot(throwError())
                expect(openCommand.arguments).toNot(beNil())
                expect(openCommand.arguments!.first!) == result.trackViewUrl
            }
        }
    }
}
