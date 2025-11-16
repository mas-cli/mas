//
// Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens Mac App Store app pages in the default web browser.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Home: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open Mac App Store app pages in the default web browser"
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async {
			await requiredAppIDsOptionGroup.forEachAppID { appID in
				let urlString = try await searcher.lookup(appID: appID).appStorePageURL
				guard let url = URL(string: urlString) else {
					throw MASError.urlParsing(urlString)
				}

				try await url.open()
			}
		}
	}
}
