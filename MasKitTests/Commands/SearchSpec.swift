//
//  SearchSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 11/12/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class SearchSpec: QuickSpec {
    override func spec() {
        describe("search") {
            context("for slack") {
                it("succeeds") {
                    let search = SearchCommand(networkSession: NetworkSessionMockFromFile(responseFile: "search/slack.json"))
                    let searchOptions = SearchOptions(appName: "slack", price: false)
                    let result = search.run(searchOptions)
                    expect(result).to(beSuccess())
                }
            }
            context("for nonexistent") {
                it("fails") {
                    let search = SearchCommand(networkSession: NetworkSessionMockFromFile(responseFile: "search/nonexistent.json"))
                    let searchOptions = SearchOptions(appName: "nonexistent", price: false)
                    let result = search.run(searchOptions)
                    expect(result).to(beFailure { error in
                        expect(error) == .noSearchResultsFound
                    })
                }
            }

            describe("url string") {
                it("contains the app name") {
                    let appName = "myapp"
                    let search = SearchCommand()
                    let urlString = search.searchURLString(appName)
                    expect(urlString) ==
                    "https://itunes.apple.com/search?entity=macSoftware&term=\(appName)&attribute=allTrackTerm"
                }
                it("contains the encoded app name") {
                    let appName = "My App"
                    let appNameEncoded = "My%20App"
                    let search = SearchCommand()
                    let urlString = search.searchURLString(appName)
                    expect(urlString) ==
                    "https://itunes.apple.com/search?entity=macSoftware&term=\(appNameEncoded)&attribute=allTrackTerm"
                }
                // FIXME: Find a character that causes addingPercentEncoding(withAllowedCharacters to return nil
                xit("is nil when app name cannot be url encoded") {
                    let appName = "`~!@#$%^&*()_+ 💩"
                    let search = SearchCommand()
                    let urlString = search.searchURLString(appName)
                    expect(urlString).to(beNil())
                }
            }
        }
    }
}
