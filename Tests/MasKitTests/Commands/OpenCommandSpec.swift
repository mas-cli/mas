//
//  OpenCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import MasKit

public class OpenCommandSpec: QuickSpec {
    override public func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "fakescheme://some/url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()
        let cmd = OpenCommand(storeSearch: storeSearch, openCommand: openCommand)

        beforeSuite {
            MasKit.initialize()
        }
        describe("open command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                let result = cmd.run(OpenCommand.Options(appId: "-999"))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .noSearchResultsFound
                        })
            }
            it("can't find app with unknown ID") {
                let result = cmd.run(OpenCommand.Options(appId: "999"))
                expect(result)
                    .to(
                        beFailure { error in
                            expect(error) == .noSearchResultsFound
                        })
            }
            it("opens app in MAS") {
                storeSearch.apps[result.trackId] = result

                let cmdResult = cmd.run(OpenCommand.Options(appId: result.trackId.description))
                expect(cmdResult).to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                let url = URL(string: openCommand.arguments!.first!)
                expect(url).toNot(beNil())
                expect(url?.scheme) == "macappstore"
            }
            it("just opens MAS if no app specified") {
                let cmdResult = cmd.run(OpenCommand.Options(appId: "appstore"))
                expect(cmdResult).to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                let url = URL(string: openCommand.arguments!.first!)
                expect(url).toNot(beNil())
                expect(url) == URL(string: "macappstore://")
            }
        }
    }
}
