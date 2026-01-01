//
// Home.swift
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
	struct Home: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open App Store app pages in the default web browser",
		)

		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async {
			await run(lookupAppFromAppID: lookup(appID:))
		}

		private func run(lookupAppFromAppID: (AppID) async throws -> CatalogApp) async {
			await run(
				catalogApps: await catalogAppIDsOptionGroup.appIDs.lookupCatalogApps(lookupAppFromAppID: lookupAppFromAppID),
			)
		}

		func run(catalogApps: [CatalogApp]) async { // swiftformat:disable:this organizeDeclarations
			await run(appStorePageURLStrings: catalogApps.map(\.appStorePageURLString))
		}

		private func run(appStorePageURLStrings: [String]) async { // swiftformat:disable:this organizeDeclarations
			await appStorePageURLStrings.forEach(attemptTo: "open") { appStorePageURLString in
				guard let url = URL(string: appStorePageURLString) else {
					throw MASError.unparsableURL(appStorePageURLString)
				}

				try await url.open()
			}
		}
	}
}
