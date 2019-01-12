//
//  OpenCommandSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class OpenCommandSpec: QuickSpec {
    override func spec() {
        let result = SearchResult(
            trackId: 1111,
            trackViewUrl: "fakescheme://some/url",
            version: "0.0"
        )
        let storeSearch = StoreSearchMock()
        let openCommand = OpenSystemCommandMock()
        let cmd = OpenCommand(storeSearch: storeSearch, openCommand: openCommand)

        describe("open command") {
            beforeEach {
                storeSearch.reset()
            }
            it("fails to open app with invalid ID") {
                let result = cmd.run(OpenCommand.Options(appId: "-999"))
                expect(result).to(beFailure { error in
                    expect(error) == .searchFailed
                })
            }
            it("can't find app with unknown ID") {
                let result = cmd.run(OpenCommand.Options(appId: "999"))
                expect(result).to(beFailure { error in
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
                storeSearch.apps[result.trackId] = result

                let cmdResult = cmd.run(OpenCommand.Options(appId: nil))
                expect(cmdResult).to(beSuccess())
                expect(openCommand.arguments).toNot(beNil())
                let url = URL(string: openCommand.arguments!.first!)
                expect(url).toNot(beNil())
                expect(url) == URL(string: "macappstore://")
            }
        }
    }
}
