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
				try await run(appCatalog: ITunesSearchAppCatalog())
			} catch {
				printer.error(error: error)
			}
		}

		func run(appCatalog: some AppCatalog) async throws {
			try run(catalogApps: try await appCatalog.search(for: searchTermOptionGroup.searchTerm))
		}

		func run(catalogApps: [CatalogApp]) throws {
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
						catalogApp.formattedPrice
					)
				}
				.joined(separator: "\n")
			)
		}
	}
}
