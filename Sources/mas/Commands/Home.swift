//
// Home.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens the App Store page for one or more apps in your default web browser.
	///
	/// This command uses the public iTunes Search API to fetch the app’s page URL,
	/// and then opens the page in your system’s default browser.
	///
	/// This can be useful for quickly viewing app details, screenshots, or reviews in the App Store.
	///
	/// > Note: This command does not output any information to the terminal.
	/// > It simply launches your web browser.
	///
	/// Example:
	/// ```bash
	/// mas home 497799835
	/// ```
	///
	/// See also:
	/// [iTunes Search API](https://performance-partners.apple.com/search-api)
	struct Home: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open Mac App Store app pages in the default web browser"
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
					guard let url = URL(string: result.trackViewUrl) else {
						throw MASError.urlParsing(result.trackViewUrl)
					}

					try await url.open()
				} catch {
					printer.error(error: error)
				}
			}
		}
	}
}
