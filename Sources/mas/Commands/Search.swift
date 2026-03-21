//
// Search.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Searches for apps in the App Store.
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Search: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Search for apps in the App Store",
		)

		@OptionGroup
		private var outputFormatOptionGroup: OutputFormatOptionGroup
		// periphery:ignore
		@Flag(help: "Output the price of each app") // swiftformat:disable:next unusedPrivateDeclarations
		private var price = false // swiftlint:disable:this unused_declaration
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try run(
				catalogApps: try await Dependencies.current.searchForAppsMatchingSearchTerm(searchTermOptionGroup.searchTerm),
			)
		}

		func run(catalogApps: [CatalogApp]) throws {
			guard !catalogApps.isEmpty else {
				throw MASError.noCatalogAppsFound(for: searchTermOptionGroup.searchTerm)
			}

			outputFormatOptionGroup.info(catalogApps.map(String.init(describing:)).joined(separator: "\n"))
		}
	}
}
