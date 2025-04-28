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
        // longest app name for right space padding
        guard let maxAppNameLength = installedApps.map(\.name.count).max() else {
            return ""
        }

        return
            installedApps.map { installedApp in
                """
                \(installedApp.id.description.padding(toLength: idColumnMinWidth, withPad: " ", startingAt: 0))\
                  \(installedApp.name.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0))\
                  (\(installedApp.version))
                """
            }
            .joined(separator: "\n")
    }
}
