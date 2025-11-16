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
	struct Search: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Search for apps in the Mac App Store"
		)

		@Flag(help: "Output the price of each app")
		var price = false
		@OptionGroup
		var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async throws {
			try await MAS.run { try await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: some AppStoreSearcher) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			let results = try await searcher.search(for: searchTerm)
			guard
				let maxADAMIDLength = results.map({ String(describing: $0.adamID).count }).max(),
				let maxNameLength = results.map(\.name.count).max()
			else {
				throw MASError.noSearchResultsFound(for: searchTerm)
			}

			let format = "%\(maxADAMIDLength)lu  %@  (%@)\(price ? "  %@" : "")"
			printer.info(
				results.map { result in
					String(
						format: format,
						result.adamID,
						result.name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0),
						result.version,
						result.formattedPrice
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
