//
// Search.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Searches for apps in the Mac App Store.
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Search: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Search for apps in the Mac App Store"
		)

		@Flag(help: "Output the price of each app")
		private var price = false
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async {
			do {
				try await run(searcher: ITunesSearchAppStoreSearcher())
			} catch {
				printer.error(error: error)
			}
		}

		func run(searcher: some AppStoreSearcher) async throws {
			try run(searchResults: try await searcher.search(for: searchTermOptionGroup.searchTerm))
		}

		func run(searchResults: [SearchResult]) throws {
			guard
				let maxADAMIDLength = searchResults.map({ String(describing: $0.adamID).count }).max(),
				let maxNameLength = searchResults.map(\.name.count).max()
			else {
				throw MASError.noSearchResultsFound(for: searchTermOptionGroup.searchTerm)
			}

			let format = "%\(maxADAMIDLength)lu  %@  (%@)\(price ? "  %@" : "")"
			printer.info(
				searchResults.map { searchResult in
					String(
						format: format,
						searchResult.adamID,
						searchResult.name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0),
						searchResult.version,
						searchResult.formattedPrice
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
