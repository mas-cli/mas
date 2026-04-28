//
// MAS.Lucky.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs the first app returned from searching the App Store (app must
	/// have been previously gotten).
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lucky: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install the first app returned from searching the App Store",
			discussion: // swiftformat:disable:next indent
				"App will install only if it has already been gotten\n\n\(requiresRootPrivilegesMessage(to: "install"))",
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async throws {
			try await run(installedApps: try await installedApps())
		}

		private func run(installedApps: [InstalledApp]) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			guard let adamID = try await Dependencies.current.searchForAppsMatchingSearchTerm(searchTerm).first?.adamID else {
				throw MASError.noCatalogAppsFound(for: searchTerm)
			}

			try await run(installedApps: installedApps, adamID: adamID)
		}

		private func run(installedApps: [InstalledApp], adamID: ADAMID) async throws {
			try await AppStore.install.apps(
				withADAMIDs: [adamID],
				force: forceOptionGroup.force,
				installedApps: installedApps,
			)
		}
	}
}
