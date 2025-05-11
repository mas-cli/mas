//
// Search.swift
// mas
//
// Created by Michael Schneider on 2016-04-14.
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

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

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			try await mas.run { try await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: AppStoreSearcher) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			let results = try await searcher.search(for: searchTerm)
			guard !results.isEmpty else {
				throw MASError.noSearchResultsFound(for: searchTerm)
			}
			printer.info(SearchResultFormatter.format(results, includePrice: price))
		}
	}
}
