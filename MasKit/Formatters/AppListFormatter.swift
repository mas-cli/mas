//
//  AppListFormatter.swift
//  MasKit
//
//  Created by Ben Chatelain on 6/7/20.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Formats text output for the search command.
struct AppListFormatter {
    /// Formats text output with list results.
    ///
    /// - Parameter products: List of sortware products app data.
    /// - Returns: Multiliune text outoutp.
    static func format(products: [SoftwareProduct]) -> String {
        // find longest appName for formatting, default 50
        let minWidth = 50
        let maxLength = products.map { $0.appNameOrBbundleIdentifier }
            .max(by: { $1.count > $0.count })?.count
            ?? minWidth

        var output: String = ""

        for product in products {
            let appId = product.itemIdentifier.intValue
            let appName = product.appNameOrBbundleIdentifier.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = product.bundleVersion

            output += String(format: "%12d  %@  (%@)\n", appId, appName, version)
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
