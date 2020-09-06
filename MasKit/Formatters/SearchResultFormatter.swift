//
//  SearchResultFormatter.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/11/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Formats text output for the search command.
struct SearchResultFormatter {
    /// Formats text output with search results.
    ///
    /// - Parameter results: Search results with app data
    /// - Returns: Multiliune text outoutp.
    static func format(results: [SearchResult], includePrice: Bool = false) -> String {
        // find longest appName for formatting, default 50
        let maxLength = results.map { $0.trackName }.max(by: { $1.count > $0.count })?.count
            ?? 50

        var output: String = ""

        for result in results {
            let appId = result.trackId
            let appName = result.trackName.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = result.version
            let price = result.price ?? 0.0

            if includePrice {
                output += String(format: "%12d  %@  $%5.2f  (%@)\n", appId, appName, price, version)
            } else {
                output += String(format: "%12d  %@ (%@)\n", appId, appName, version)
            }
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
