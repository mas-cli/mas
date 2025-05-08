//
// SearchResultFormatter.swift
// mas
//
// Created by Ben Chatelain on 2019-01-11.
// Copyright © 2019 mas-cli. All rights reserved.
//

/// Formats text output for the search command.
enum SearchResultFormatter {
	/// Formats search results as text.
	///
	/// - Parameters:
	///   - results: Search results containing app data
	///   - includePrice: Indicates whether to include prices in the output
	/// - Returns: Multiline text output.
	static func format(_ results: [SearchResult], includePrice: Bool = false) -> String {
		guard let maxAppNameLength = results.map(\.trackName.count).max() else {
			return ""
		}

		return
			results.map { result in
				String(
					format: includePrice ? "%12lu  %@  (%@)  %@" : "%12lu  %@  (%@)",
					result.trackId,
					result.trackName.padding(toLength: maxAppNameLength, withPad: " ", startingAt: 0),
					result.version,
					result.outputPrice
				)
			}
			.joined(separator: "\n")
	}
}
