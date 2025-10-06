//
// Vendor.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens apps' vendor pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Vendor: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open apps' vendor pages in the default web browser"
		)

		@OptionGroup
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			try await MAS.run { await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: AppStoreSearcher) async {
			await requiredAppIDsOptionGroup.forEachAppID(printer: printer) { appID in
				guard let urlString = try await searcher.lookup(appID: appID).vendorURL else {
					throw MASError.noVendorWebsite(forAppID: appID)
				}
				guard let url = URL(string: urlString) else {
					throw MASError.urlParsing(urlString)
				}

				try await url.open()
			}
		}
	}
}
