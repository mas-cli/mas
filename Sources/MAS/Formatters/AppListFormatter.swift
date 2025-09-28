//
// AppListFormatter.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation

/// Formats text output for the search command.
enum AppListFormatter {
	/// Formats text output with list results.
	///
	/// - Parameter installedApps: List of installed apps.
	/// - Returns: Multiline text output.
	static func format(_ installedApps: [InstalledApp]) -> String {
		guard let maxADAMIDLength = installedApps.map({ String(describing: $0.adamID).count }).max() else {
			return ""
		}
		guard let maxAppNameLength = installedApps.map(\.name.count).max() else {
			return ""
		}

		let format = "%\(maxADAMIDLength)lu  %@  (%@)"
		return
			installedApps.map { installedApp in
				String(
					format: format,
					installedApp.adamID,
					installedApp.name.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0),
					installedApp.version
				)
			}
			.joined(separator: "\n")
	}
}
