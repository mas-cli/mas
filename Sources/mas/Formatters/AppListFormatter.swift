//
//  AppListFormatter.swift
//  mas
//
//  Created by Ben Chatelain on 6/7/20.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// Formats text output for the search command.
enum AppListFormatter {
    static let idColumnMinWidth = 10

    /// Formats text output with list results.
    ///
    /// - Parameter products: List of software products app data.
    /// - Returns: Multiline text output.
    static func format(products: [SoftwareProduct]) -> String {
        // find longest appName for formatting
        let maxLength = products.map(\.appName.count).max() ?? 0

        var output = ""

        for product in products {
            let appID = product.itemIdentifier.stringValue
                .padding(toLength: idColumnMinWidth, withPad: " ", startingAt: 0)
            let appName = product.appName.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = product.bundleVersion

            output += "\(appID)  \(appName)  (\(version))\n"
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
