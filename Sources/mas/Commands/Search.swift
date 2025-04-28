//
//  Search.swift
//  mas
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Search the Mac App Store. Uses the iTunes Search API:
	/// https://performance-partners.apple.com/search-api
	struct Search: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Search for apps from the Mac App Store"
		)

		@Flag(help: "Display the price of each app")
		var price = false
		@Argument(help: "Search term")
		var searchTerm: String

		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			do {
				let results = try await searcher.search(for: searchTerm)
				if results.isEmpty {
					throw MASError.noSearchResultsFound
				}

				print(SearchResultFormatter.format(results, includePrice: price))
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.searchFailed
			}
		}
	}
}
