//
// Search.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Searches the Mac App Store for apps matching a given search term.
	///
	/// This command uses the public iTunes Search API to look up apps by keyword.
	/// It returns the App ID and app name for each match, which can be used with
	/// other commands such as `mas install`, `mas info`, or `mas lucky`.
	///
	/// Use the `--price` flag to also display each app’s current price.
	///
	/// Example:
	/// ```bash
	/// mas search Xcode
	/// ```
	///
	/// Output:
	/// ```
	/// 497799835 Xcode
	/// 688199928 Docs for Xcode
	/// ```
	///
	/// Example with price:
	/// ```bash
	/// mas search Xcode --price
	/// 497799835 Xcode - Free
	/// 688199928 Docs for Xcode - ¥100
	/// ```
	///
	/// > Note:
	/// > Search results may vary depending on your App Store region (`mas region`)
	///
	/// See also:
	/// [iTunes Search API](https://performance-partners.apple.com/search-api)
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
