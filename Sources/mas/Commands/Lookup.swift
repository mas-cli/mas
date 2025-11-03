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
	struct Lookup: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the Mac App Store",
			aliases: ["info"]
		)

		@OptionGroup
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: some AppStoreSearcher) async throws {
			try await MAS.run { await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: some AppStoreSearcher) async {
			var spacing = ""
			await requiredAppIDsOptionGroup.forEachAppID(printer: printer) { appID in
				let result = try await searcher.lookup(appID: appID)
				printer.info(
					"",
					"""
					\(result.name) \(result.version) [\(result.formattedPrice)]
					By: \(result.sellerName)
					Released: \(result.releaseDate.humanReadableDate)
					Minimum OS: \(result.minimumOSVersion)
					Size: \(result.fileSizeBytes.humanReadableSize)
					From: \(result.appStorePageURL)
					""",
					separator: spacing
				)
				spacing = "\n"
			}
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
