//
// Lookup.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Outputs app information from the App Store.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lookup: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the App Store",
			aliases: ["info"],
		)

		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async {
			await run(lookupAppFromAppID: lookup(appID:))
		}

		private func run(lookupAppFromAppID: (AppID) async throws -> CatalogApp) async {
			run(catalogApps: await catalogAppIDsOptionGroup.appIDs.lookupCatalogApps(lookupAppFromAppID: lookupAppFromAppID))
		}

		func run(catalogApps: [CatalogApp]) { // swiftformat:disable:this organizeDeclarations
			printer.info(
				catalogApps.map { catalogApp in
					"""
					\(catalogApp.name) \(catalogApp.version) [\(catalogApp.displayPrice)]
					By: \(catalogApp.sellerName)
					Released: \(catalogApp.releaseDate.isoCalendarDate)
					Minimum OS: \(catalogApp.minimumOSVersion)
					Size: \(catalogApp.fileSizeBytes.humanReadableSize)
					From: \(catalogApp.appStorePageURLString)

					"""
				}
				.joined(separator: "\n"),
				terminator: "",
			)
		}
	}
}

private extension String {
	var humanReadableSize: Self {
		Int64(self).map { $0.formatted(.byteCount(style: .file, allowedUnits: .mb, spellsOutZero: false)) } ?? self
	}

	var isoCalendarDate: Self {
		(try? Date(self, strategy: .iso8601).formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day()))
		?? self // swiftformat:disable:this indent
	}
}
