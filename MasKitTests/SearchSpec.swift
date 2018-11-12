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
                it("is nil when app name cannot be url encoded") {
                    let appName = "💩"
                    let search = SearchCommand()
                    let urlString = search.searchURLString(appName)
                    expect(urlString).to(beNil())
                }
            }
        }
    }
}
