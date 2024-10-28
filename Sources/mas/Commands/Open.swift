//
//  Open.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import AppKit
import ArgumentParser
import Foundation
import PromiseKit

private let masScheme = "macappstore"

extension MAS {
    /// Opens app page in MAS app. Uses the iTunes Lookup API:
    /// https://performance-partners.apple.com/search-api
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open app page in 'App Store.app'"
        )

        @Argument(help: "App ID")
        var appID: AppID?

        /// Runs the command.
        func run() throws {
            try run(searcher: ITunesSearchAppStoreSearcher())
        }

        func run(searcher: AppStoreSearcher) throws {
            guard let appID else {
                // If no app ID is given, just open the MAS GUI app
                try openMacAppStore().wait()
                return
            }
            try openInMacAppStore(pageForAppID: appID, searcher: searcher).wait()
        }
    }
}

private func openMacAppStore() -> Promise<Void> {
    Promise { seal in
        guard let macappstoreSchemeURL = URL(string: "macappstore:") else {
            throw MASError.notSupported
        }
        guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: macappstoreSchemeURL) else {
            throw MASError.notSupported
        }

        if #available(macOS 10.15, *) {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration()) { _, error in
                if let error {
                    seal.reject(error)
                }
                seal.fulfill(())
            }
        } else {
            try NSWorkspace.shared.launchApplication(at: appURL, configuration: [:])
            seal.fulfill(())
        }
    }
}

private func openInMacAppStore(pageForAppID appID: AppID, searcher: AppStoreSearcher) -> Promise<Void> {
    Promise { seal in
        guard let result = try searcher.lookup(appID: appID).wait() else {
            throw MASError.runtimeError("Unknown app ID \(appID)")
        }

        guard var urlComponents = URLComponents(string: result.trackViewUrl) else {
            throw MASError.runtimeError("Unable to construct URL from: \(result.trackViewUrl)")
        }

        urlComponents.scheme = masScheme

        guard let url = urlComponents.url else {
            throw MASError.runtimeError("Unable to construct URL from: \(urlComponents)")
        }

        if #available(macOS 10.15, *) {
            NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration()) { _, error in
                if let error {
                    seal.reject(error)
                }
                seal.fulfill(())
            }
        } else {
            NSWorkspace.shared.open(url)
            seal.fulfill(())
        }
    }
}
