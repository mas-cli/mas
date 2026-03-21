//
// Lookup.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs app information from the App Store.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lookup: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the App Store",
			aliases: ["info"],
		)

		@OptionGroup
		private var outputFormatOptionGroup: OutputFormatOptionGroup
		@OptionGroup
		private var catalogAppIDsOptionGroup: CatalogAppIDsOptionGroup

		func run() async {
			run(catalogApps: await catalogAppIDsOptionGroup.appIDs.catalogApps)
		}

		func run(catalogApps: [CatalogApp]) {
			outputFormatOptionGroup.info(catalogApps.map { "\($0)\n" }.joined(), terminator: "")
		}
	}
}
