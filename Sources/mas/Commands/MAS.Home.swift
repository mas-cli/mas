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
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async {
			await run(catalogApps: await catalogAppIDsOptionGroup.appIDs.catalogApps)
		}

		func run(catalogApps: [CatalogApp]) async {
			await run(appStorePageURLStrings: catalogApps.map(\.appStorePageURLString))
		}

		private func run(appStorePageURLStrings: [String]) async {
			await appStorePageURLStrings.forEach(attemptTo: "open") { appStorePageURLString in
				guard let url = URL(string: appStorePageURLString) else {
					throw MASError.invalidURL(appStorePageURLString)
				}

				_ = try await url.open()
			}
		}
	}
}
