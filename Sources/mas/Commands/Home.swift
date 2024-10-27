//
//  Home.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser

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
            try run(searcher: ITunesSearchAppStoreSearcher(), openCommand: OpenSystemCommand())
        }

        func run(searcher: AppStoreSearcher, openCommand: ExternalCommand) throws {
            do {
                guard let result = try searcher.lookup(appID: appID).wait() else {
                    throw MASError.noSearchResultsFound
                }

                do {
                    try openCommand.run(arguments: result.trackViewUrl)
                } catch {
                    printError("Unable to launch open command")
                    throw MASError.searchFailed
                }
                if openCommand.failed {
                    let reason = openCommand.process.terminationReason
                    printError("Open failed: (\(reason)) \(openCommand.stderr)")
                    throw MASError.searchFailed
                }
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
