//
//  SearchResultFormatter.swift
//  mas
//
//  Created by Ben Chatelain on 1/11/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// Formats text output for the search command.
enum SearchResultFormatter {
    /// Formats search results as text.
    ///
    /// - Parameters:
    ///   - results: Search results containing app data
    ///   - includePrice: Indicates whether to include prices in the output
    /// - Returns: Multiline text output.
    static func format(_ results: [SearchResult], includePrice: Bool = false) -> String {
        // longest app name for right space padding
        guard let maxAppNameLength = results.map(\.trackName.count).max() else {
            return ""
        }

        return
            results.map { result in
                let appID = result.trackId
                let appName = result.trackName.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0)
                let version = result.version

                return includePrice
                    ? String(format: "%12lu  %@  (%@)  %@", appID, appName, version, result.displayPrice)
                    : String(format: "%12lu  %@  (%@)", appID, appName, version)
            }
            .joined(separator: "\n")
    }
}
