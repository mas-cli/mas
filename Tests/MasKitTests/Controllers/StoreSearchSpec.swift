//
//  StoreSearchSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/11/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//
import Nimble
import Quick

@testable import MasKit

/// Protocol minimal implementation
struct StoreSearchForTesting: StoreSearch {
    func lookup(app _: Int, _ completion: @escaping (SearchResult?, Error?) -> Void) {
        completion(nil, nil)
    }

    func search(for _: String, _ completion: @escaping ([SearchResult]?, Error?) -> Void) {
        completion([], nil)
    }
}

public class StoreSearchSpec: QuickSpec {
    override public func spec() {
        let storeSearch = StoreSearchForTesting()

        describe("url string") {
            it("contains the app name") {
                let appName = "myapp"
                let urlString = storeSearch.searchURL(for: appName)?.absoluteString
                expect(urlString) == "https://itunes.apple.com/search?media=software&entity=macSoftware&term=\(appName)"
            }
            it("contains the encoded app name") {
                let appName = "My App"
                let appNameEncoded = "My%20App"
                let urlString = storeSearch.searchURL(for: appName)?.absoluteString
                expect(urlString)
                    == "https://itunes.apple.com/search?media=software&entity=macSoftware&term=\(appNameEncoded)"
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
