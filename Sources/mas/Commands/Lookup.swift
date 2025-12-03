//
// Lookup.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation
private import ObjectiveC

extension MAS {
	/// Outputs app information from the App Store.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lookup: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the App Store",
			aliases: ["info"]
		)

		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			await run(appCatalog: ITunesSearchAppCatalog())
		}

		private func run(appCatalog: some AppCatalog) async {
			run(catalogApps: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(from: appCatalog))
		}

		func run(catalogApps: [CatalogApp]) { // swiftformat:disable:this organizeDeclarations
			printer.info(
				catalogApps.map { catalogApp in
					"""
					\(catalogApp.name) \(catalogApp.version) [\(catalogApp.formattedPrice)]
					By: \(catalogApp.sellerName)
					Released: \(catalogApp.releaseDate.isoCalendarDate)
					Minimum OS: \(catalogApp.minimumOSVersion)
					Size: \(catalogApp.fileSizeBytes.humanReadableSize)
					From: \(catalogApp.appStorePageURLString)

					"""
				}
				.joined(separator: "\n"),
				terminator: ""
			)
		}
	}
}

private extension String {
	var humanReadableSize: Self {
		Int64(self).map { size in
			let formatter = ByteCountFormatter()
			formatter.allowedUnits = .useMB
			formatter.allowsNonnumericFormatting = false
			return formatter.string(fromByteCount: size)
		}
		?? self // swiftformat:disable:this indent
	}

	var isoCalendarDate: Self {
		ISO8601DateFormatter().date(from: self).map { date in
			ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: [.withFullDate])
		}
		?? self // swiftformat:disable:this indent
	}
}
