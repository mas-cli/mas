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
	struct Search: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Search for apps in the App Store"
		)

		@Flag(help: "Output the price of each app")
		private var price = false
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try await run(searchForAppsMatchingSearchTerm: search(for:))
		}

		private func run(searchForAppsMatchingSearchTerm: (String) async throws -> [CatalogApp]) async throws {
			try run(catalogApps: try await searchForAppsMatchingSearchTerm(searchTermOptionGroup.searchTerm))
		}

		func run(catalogApps: [CatalogApp]) throws { // swiftformat:disable:this organizeDeclarations
			guard
				let maxADAMIDLength = catalogApps.map({ String(describing: $0.adamID).count }).max(),
				let maxNameLength = catalogApps.map(\.name.count).max()
			else {
				throw MASError.noCatalogAppsFound(for: searchTermOptionGroup.searchTerm)
			}

			let format = "%\(maxADAMIDLength)lu  %@  (%@)\(price ? "  %@" : "")"
			printer.info(
				catalogApps.map { catalogApp in
					String(
						format: format,
						catalogApp.adamID,
						catalogApp.name.padding(toLength: maxNameLength, withPad: " ", startingAt: 0),
						catalogApp.version,
						catalogApp.displayPrice
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
