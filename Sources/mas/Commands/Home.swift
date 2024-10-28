//
//  Home.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Opens app page on MAS Preview. Uses the iTunes Lookup API:
    /// https://performance-partners.apple.com/search-api
    struct Home: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open app's Mac App Store web page in the default web browser"
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

            guard let url = URL(string: result.trackViewUrl) else {
                throw MASError.runtimeError("Unable to construct URL from: \(result.trackViewUrl)")
            }

            try url.open().wait()
        }
    }
}
