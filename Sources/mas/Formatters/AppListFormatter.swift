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
    /// - Parameter installedApps: List of installed apps.
    /// - Returns: Multiline text output.
    static func format(_ installedApps: [InstalledApp]) -> String {
        // find longest appName for formatting
        let maxLength = installedApps.map(\.appName.count).max() ?? 0

        var output = ""

        for installedApp in installedApps {
            let appID = installedApp.appID.description.padding(toLength: idColumnMinWidth, withPad: " ", startingAt: 0)
            let appName = installedApp.appName.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let version = installedApp.bundleVersion

            output += "\(appID)  \(appName)  (\(version))\n"
        }

        return output.trimmingCharacters(in: .newlines)
    }
}
