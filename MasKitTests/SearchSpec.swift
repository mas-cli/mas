//
//  SearchSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 11/12/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Quick
import Nimble

class SearchSpec: QuickSpec {
    override func spec() {
        describe("search") {
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
