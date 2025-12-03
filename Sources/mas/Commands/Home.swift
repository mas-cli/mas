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
			abstract: "Open App Store app pages in the default web browser"
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
			await run(appStorePageURLs: catalogApps.map(\.appStorePageURL))
		}

		private func run(appStorePageURLs: [String]) async { // swiftformat:disable:this organizeDeclarations
			await appStorePageURLs.forEach(attemptTo: "open") { appStorePageURL in
				guard let url = URL(string: appStorePageURL) else {
					throw MASError.unparsableURL(appStorePageURL)
				}

				try await url.open()
			}
		}
	}
}
