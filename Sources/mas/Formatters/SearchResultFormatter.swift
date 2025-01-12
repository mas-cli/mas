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
    static func format(results: [SearchResult], includePrice: Bool = false) -> String {
        guard let maxLength = results.map(\.trackName.count).max() else {
            return ""
        }

        var output = ""

        for result in results {
            let appID = result.trackId
            let appName = result.trackName.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = result.version

            if includePrice {
                output += String(format: "%12lu  %@  (%@)  %@\n", appID, appName, version, result.displayPrice)
            } else {
                output += String(format: "%12lu  %@  (%@)\n", appID, appName, version)
            }
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
