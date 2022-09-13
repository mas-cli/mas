//
//  StoreSearchSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/11/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import PromiseKit
import Quick

@testable import MasKit

/// Protocol minimal implementation
struct StoreSearchForTesting: StoreSearch {
    func lookup(app _: Int) -> Promise<SearchResult?> {
        .value(nil)
    }

    func search(for _: String) -> Promise<[SearchResult]> {
        .value([])
    }
}

public class StoreSearchSpec: QuickSpec {
    override public func spec() {
        let storeSearch = StoreSearchForTesting()
        let region = Locale.autoupdatingCurrent.regionCode!

        describe("url string") {
            it("contains the app name") {
                let appName = "myapp"
                let urlString = storeSearch.searchURL(for: appName)?.absoluteString
                expect(urlString) == "https://itunes.apple.com/search?"
                    + "media=software&entity=macSoftware&term=\(appName)&country=\(region)"
            }
            it("contains the encoded app name") {
                let appName = "My App"
                let appNameEncoded = "My%20App"
                let urlString = storeSearch.searchURL(for: appName)?.absoluteString
                expect(urlString) == "https://itunes.apple.com/search?"
                    + "media=software&entity=macSoftware&term=\(appNameEncoded)&country=\(region)"
            }
            // Find a character that causes addingPercentEncoding(withAllowedCharacters to return nil
            xit("is nil when app name cannot be url encoded") {
                let appName = "`~!@#$%^&*()_+ 💩"
                let urlString = storeSearch.searchURL(for: appName)?.absoluteString
                expect(urlString).to(beNil())
            }
        }
    }
}
