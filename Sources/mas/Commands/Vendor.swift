//
//  Vendor.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser

extension Mas {
    /// Opens vendor's app page in a browser. Uses the iTunes Lookup API:
    /// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
    struct Vendor: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Opens vendor's app page in a browser"
        )

        @Argument(help: "the app ID to show the vendor's website")
        var appID: AppID

        /// Runs the command.
        func run() throws {
            try run(storeSearch: MasStoreSearch(), openCommand: OpenSystemCommand())
        }

        func run(storeSearch: StoreSearch, openCommand: ExternalCommand) throws {
            do {
                guard let result = try storeSearch.lookup(appID: appID).wait()
                else {
                    throw MASError.noSearchResultsFound
                }

                guard let vendorWebsite = result.sellerUrl
                else { throw MASError.noVendorWebsite }

                do {
                    try openCommand.run(arguments: vendorWebsite)
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
