//
//  SearchResultFormatter.swift
//  mas
//
//  Created by Ben Chatelain on 1/11/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Formats text output for the search command.
enum SearchResultFormatter {
    /// Formats text output with search results.
    ///
    /// - Parameter results: Search results with app data
    /// - Returns: Multiline text output.
    static func format(results: [SearchResult], includePrice: Bool = false) -> String {
        // find longest appName for formatting, default 50
        let maxLength = results.map(\.trackName.count).max() ?? 50
        var output = ""

        for result in results {
            let appID = result.trackId
            let appName = result.trackName.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = result.version
            let price = result.price ?? 0.0

            if includePrice {
                output += String(format: "%12lu  %@  $%5.2f  (%@)\n", appID, appName, price, version)
            } else {
                output += String(format: "%12lu  %@ (%@)\n", appID, appName, version)
            }
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
