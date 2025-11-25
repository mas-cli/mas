//
// Lucky.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Installs the first app returned from searching the App Store (app must
	/// have been previously gotten).
	///
	/// Uses the iTunes Search API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Lucky: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Install the first app returned from searching the App Store",
			discussion: "App will install only if it has already been gotten\n\(requiresRootPrivilegesMessage)"
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var searchTermOptionGroup: SearchTermOptionGroup

		func run() async {
			do {
				try requireRootUserAndWheelGroup(withErrorMessageSuffix: "to install apps")
				try await ProcessInfo.processInfo.runAsSudoEffectiveUserAndSudoEffectiveGroup {
					try await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
				}
			} catch {
				printer.error(error: error)
			}
		}

		private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
			let searchTerm = searchTermOptionGroup.searchTerm
			guard let adamID = try await appCatalog.search(for: searchTerm).first?.adamID else {
				throw MASError.noCatalogAppsFound(for: searchTerm)
			}

			try await run(installedApps: installedApps, adamID: adamID)
		}

		private func run(installedApps: [InstalledApp], adamID: ADAMID) async throws {
			try await downloadApp(withADAMID: adamID, forceDownload: forceOptionGroup.force, installedApps: installedApps)
		}
	}
}
