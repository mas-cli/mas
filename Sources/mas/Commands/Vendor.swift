//
// Vendor.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens the vendor (developer) website for the given app(s) in your default web browser.
	///
	/// This command queries the App Store for the specified app(s) and opens the developer's
	/// website as provided in the app metadata (`sellerUrl`). This can help verify the identity
	/// of app publishers or locate official support and documentation sites.
	///
	/// > Tip:
	/// > Use `mas info` or `mas search` to find the App ID before using this command.
	///
	/// Example:
	/// ```bash
	/// mas vendor 497799835
	/// ```
	///
	/// > Note:
	/// > If the vendor does not provide a website (`sellerUrl`), this command will return an error.
	struct Vendor: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open apps' vendor pages in the default web browser"
		)

		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			try await mas.run { await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: AppStoreSearcher) async {
			for appID in appIDsOptionGroup.appIDs {
				do {
					let result = try await searcher.lookup(appID: appID)
					guard let urlString = result.sellerUrl else {
						throw MASError.noVendorWebsite(forAppID: appID)
					}
					guard let url = URL(string: urlString) else {
						throw MASError.urlParsing(urlString)
					}

					try await url.open()
				} catch {
					printer.error(error: error)
				}
			}
		}
	}
}
