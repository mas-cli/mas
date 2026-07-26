//
// MAS.Seller.swift
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
		private var catalogAppsOptionGroup: CatalogAppsOptionGroup

		func run() async {
			await run(catalogApps: await catalogAppsOptionGroup.appIDs.catalogApps)
		}

		func run(catalogApps: [CatalogApp]) async {
			await catalogApps.forEach(attemptTo: "open") { catalogApp in
				guard let sellerURLString = catalogApp.sellerURLString else {
					printer.error("Failed to find seller app web page for ADAM ID", catalogApp.adamID)
					return
				}
				guard let url = URL(string: sellerURLString) else {
					throw MASError.invalidURL(sellerURLString)
				}

				_ = try await url.open()
			}
		}
	}
}
