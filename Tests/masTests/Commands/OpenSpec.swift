//
//  OpenSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class OpenSpec: QuickSpec {
    override public static func spec() {
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()

        beforeSuite {
            Mas.initialize()
        }
        describe("open command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                expect {
                    try Mas.Open.parse(["--", "-999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError())
            }
            it("can't find app with unknown ID") {
                expect {
                    try Mas.Open.parse(["999"]).run(storeSearch: storeSearch, openCommand: openCommand)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
            it("opens app in MAS") {
                let mockResult = SearchResult(
                    trackId: 1111,
                    trackViewUrl: "fakescheme://some/url",
                    version: "0.0"
                )
                storeSearch.apps[mockResult.trackId] = mockResult
                expect {
                    try Mas.Open.parse([mockResult.trackId.description])
                        .run(storeSearch: storeSearch, openCommand: openCommand)
                    return openCommand.arguments
                }
                    == ["macappstore://some/url"]
            }
            it("just opens MAS if no app specified") {
                expect {
                    try Mas.Open.parse([]).run(storeSearch: storeSearch, openCommand: openCommand)
                    return openCommand.arguments
                }
                    == ["macappstore://"]
            }
        }
    }
}
