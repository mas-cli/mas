//
//  Info.swift
//  mas
//
//  Created by Denis Lebedev on 21/10/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Displays app details. Uses the iTunes Lookup API:
    /// https://performance-partners.apple.com/search-api
    struct Info: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display app information from the Mac App Store"
        )

        @Argument(help: "App ID")
        var appID: AppID

        /// Runs the command.
        func run() throws {
            try run(searcher: ITunesSearchAppStoreSearcher())
        }

        func run(searcher: AppStoreSearcher) throws {
            do {
                print(AppInfoFormatter.format(app: try searcher.lookup(appID: appID).wait()))
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
