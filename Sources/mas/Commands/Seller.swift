//
// Seller.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens apps' seller pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Seller: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open apps' seller pages in the default web browser",
			aliases: ["vendor"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			await run(lookupAppFromAppID: lookup(appID:))
		}

		private func run(lookupAppFromAppID: (AppID) async throws -> CatalogApp) async {
			await run(
				catalogApps: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(lookupAppFromAppID: lookupAppFromAppID)
			)
		}

		func run(catalogApps: [CatalogApp]) async { // swiftformat:disable:this organizeDeclarations
			await run(
				sellerURLStrings: catalogApps.compactMap { catalogApp in
					guard let sellerURLString = catalogApp.sellerURLString else {
						printer.error("No seller website available for ADAM ID", catalogApp.adamID)
						return nil
					}

					return sellerURLString
				}
			)
		}

		private func run(sellerURLStrings: [String]) async { // swiftformat:disable:this organizeDeclarations
			await sellerURLStrings.forEach(attemptTo: "open") { sellerURLString in
				guard let url = URL(string: sellerURLString) else {
					throw MASError.unparsableURL(sellerURLString)
				}

				try await url.open()
			}
		}
	}
}
