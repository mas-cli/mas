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
			await run(appCatalog: ITunesSearchAppCatalog())
		}

		func run(appCatalog: some AppCatalog) async {
			run(catalogApps: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(from: appCatalog))
		}

		func run(catalogApps: [CatalogApp]) {
			guard !catalogApps.isEmpty else {
				return
			}

			printer.info(
				catalogApps.map { catalogApp in
					"""
					\(catalogApp.name) \(catalogApp.version) [\(catalogApp.formattedPrice)]
					By: \(catalogApp.sellerName)
					Released: \(catalogApp.releaseDate.humanReadableDate)
					Minimum OS: \(catalogApp.minimumOSVersion)
					Size: \(catalogApp.fileSizeBytes.humanReadableSize)
					From: \(catalogApp.appStorePageURL)
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
