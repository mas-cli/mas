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
	struct Seller: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open apps' seller pages in the default web browser",
			aliases: ["vendor"],
		)

		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async {
			await run(catalogApps: await catalogAppIDsOptionGroup.appIDs.catalogApps)
		}

		func run(catalogApps: [CatalogApp]) async {
			await run(
				sellerURLStrings: catalogApps.compactMap { catalogApp in
					guard let sellerURLString = catalogApp.sellerURLString else {
						printer.error("No seller website available for ADAM ID", catalogApp.adamID)
						return nil
					}

					return sellerURLString
				},
			)
		}

		private func run(sellerURLStrings: [String]) async {
			await sellerURLStrings.forEach(attemptTo: "open") { sellerURLString in
				guard let url = URL(string: sellerURLString) else {
					throw MASError.invalidURL(sellerURLString)
				}

				_ = try await url.open()
			}
		}
	}
}
