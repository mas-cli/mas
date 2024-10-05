//
//  AppListFormatter.swift
//  MasKit
//
//  Created by Ben Chatelain on 6/7/20.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Formats text output for the search command.
enum AppListFormatter {
    static let idColumnMinWidth = 10
    static let nameColumnMinWidth = 50

    /// Formats text output with list results.
    ///
    /// - Parameter products: List of software products app data.
    /// - Returns: Multiline text output.
    static func format(products: [SoftwareProduct]) -> String {
        // find longest appName for formatting, default 50
        let maxLength = products.map(\.appNameOrBundleIdentifier.count).max() ?? nameColumnMinWidth

        var output = ""

        for product in products {
            let appId = product.itemIdentifier.stringValue
                .padding(toLength: idColumnMinWidth, withPad: " ", startingAt: 0)
            let appName = product.appNameOrBundleIdentifier.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = product.bundleVersion

            output += "\(appId)  \(appName)  (\(version))\n"
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
