//
// SearchResultFormatter.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import Foundation

/// Formats text output for the search command.
enum SearchResultFormatter {
	/// Formats search results as text.
	///
	/// - Parameters:
	///   - results: Search results containing app data
	///   - includePrice: Indicates whether to include prices in the output
	/// - Returns: Multiline text output.
	static func format(_ results: [SearchResult], includePrice: Bool = false) -> String {
		guard let maxAdamIDLength = results.map(\.adamID.description.count).max() else {
			return ""
		}
		guard let maxAppNameLength = results.map(\.trackName.count).max() else {
			return ""
		}

		let format = "%\(maxAdamIDLength)lu  %@  (%@)\(includePrice ? "  %@" : "")"
		return
			results.map { result in
				String(
					format: format,
					result.adamID,
					result.trackName.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0),
					result.version,
					result.outputPrice
				)
			}
			.joined(separator: "\n")
	}
}
