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
			await run(appCatalog: ITunesSearchAppCatalog())
		}

		private func run(appCatalog: some AppCatalog) async {
			await run(catalogApps: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(from: appCatalog))
		}

		func run(catalogApps: [CatalogApp]) async { // swiftformat:disable:this organizeDeclarations
			await run(
				sellerURLs: catalogApps.compactMap { catalogApp in
					guard let sellerURL = catalogApp.sellerURL else {
						printer.error("No seller website available for ADAM ID", catalogApp.adamID)
						return nil
					}

					return sellerURL
				}
			)
		}

		private func run(sellerURLs: [String]) async { // swiftformat:disable:this organizeDeclarations
			await sellerURLs.forEach(attemptTo: "open") { sellerURL in
				guard let url = URL(string: sellerURL) else {
					throw MASError.urlParsing(sellerURL)
				}

				try await url.open()
			}
		}
	}
}
