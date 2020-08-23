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

    static let idColumnMinWidth = 10
    static let nameColumnMinWidth = 50

    /// Formats text output with list results.
    ///
    /// - Parameter products: List of sortware products app data.
    /// - Returns: Multiliune text outoutp.
    static func format(products: [SoftwareProduct]) -> String {
        // find longest appName for formatting, default 50
        let maxLength = products.map { $0.appNameOrBbundleIdentifier }
            .max(by: { $1.count > $0.count })?.count
            ?? nameColumnMinWidth

        var output: String = ""

        for product in products {
            let appId = product.itemIdentifier.stringValue
                .padding(toLength: idColumnMinWidth, withPad: " ", startingAt: 0)
            let appName = product.appNameOrBbundleIdentifier.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = product.bundleVersion

            output += "\(appId)  \(appName)  (\(version))\n"
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
