//
// Lookup.swift
// mas
//
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
	struct Lookup: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the Mac App Store",
			aliases: ["info"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async {
			run(searchResults: await requiredAppIDsOptionGroup.appIDs.lookupResults(from: searcher))
		}

		func run(searchResults: [SearchResult]) {
			guard !searchResults.isEmpty else {
				return
			}

			printer.info(
				searchResults.map { searchResult in
					"""
					\(searchResult.name) \(searchResult.version) [\(searchResult.formattedPrice)]
					By: \(searchResult.sellerName)
					Released: \(searchResult.releaseDate.humanReadableDate)
					Minimum OS: \(searchResult.minimumOSVersion)
					Size: \(searchResult.fileSizeBytes.humanReadableSize)
					From: \(searchResult.appStorePageURL)
					"""
				}
				.joined(separator: "\n\n")
			)
		}
	}
}

private extension String {
	var humanReadableSize: String {
		ByteCountFormatter.string(fromByteCount: Int64(self) ?? 0, countStyle: .file)
	}

	var humanReadableDate: String {
		ISO8601DateFormatter().date(from: self).map { date in
			ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: [.withFullDate])
		}
		?? "" // swiftformat:disable:this indent
	}
}
