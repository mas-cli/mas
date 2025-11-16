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
			await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async {
			await requiredAppIDsOptionGroup.forEachAppID { appID in
				guard let urlString = try await searcher.lookup(appID: appID).sellerURL else {
					throw MASError.runtimeError("No seller website available for \(appID)")
				}
				guard let url = URL(string: urlString) else {
					throw MASError.urlParsing(urlString)
				}

				try await url.open()
			}
		}
	}
}
