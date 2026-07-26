//
// MAS.Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens App Store app pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Home: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open App Store app pages in the default web browser",
		)

		@OptionGroup
		private var catalogAppsOptionGroup: CatalogAppsOptionGroup

		func run() async {
			await run(catalogApps: await catalogAppsOptionGroup.appIDs.catalogApps)
		}

		func run(catalogApps: [CatalogApp]) async {
			await catalogApps.forEach(attemptTo: "open") { catalogApp in
				guard let url = URL(string: catalogApp.appStorePageURLString) else {
					throw MASError.invalidURL(catalogApp.appStorePageURLString)
				}

				_ = try await url.open()
			}
		}
	}
}
