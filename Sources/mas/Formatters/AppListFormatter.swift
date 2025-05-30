//
// AppListFormatter.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

/// Formats text output for the search command.
enum AppListFormatter {
	static let idColumnMinWidth = 10

	/// Formats text output with list results.
	///
	/// - Parameter installedApps: List of installed apps.
	/// - Returns: Multiline text output.
	static func format(_ installedApps: [InstalledApp]) -> String {
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
