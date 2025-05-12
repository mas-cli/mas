//
// Info.swift
// mas
//
// Created by Denis Lebedev on 2016-10-21.
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Outputs app information from the Mac App Store.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Info: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the Mac App Store"
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
			var spacing = ""
			for appID in appIDsOptionGroup.appIDs {
				do {
					printer.info("", AppInfoFormatter.format(app: try await searcher.lookup(appID: appID)), separator: spacing)
				} catch {
					printer.log(spacing, to: .standardError)
					printer.error(error: error)
				}
				spacing = "\n"
			}
		}
	}
}
