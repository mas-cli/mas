//
//  Vendor.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Opens vendor's app page in a browser. Uses the iTunes Lookup API:
    /// https://performance-partners.apple.com/search-api
    struct Vendor: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open vendor's app web page in the default web browser"
        )

        @Argument(help: "App ID")
        var appID: AppID

        /// Runs the command.
        func run() throws {
            try run(searcher: ITunesSearchAppStoreSearcher())
        }

        func run(searcher: AppStoreSearcher) throws {
            guard let result = try searcher.lookup(appID: appID).wait() else {
                throw MASError.noSearchResultsFound
            }

            guard let urlString = result.sellerUrl else {
                throw MASError.noVendorWebsite
            }

            guard let url = URL(string: urlString) else {
                throw MASError.runtimeError("Unable to construct URL from: \(urlString)")
            }

            try url.open().wait()
        }
    }
}
