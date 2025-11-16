//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously gotten apps from the Mac App Store.
	struct Install: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Install previously gotten apps from the Mac App Store"
		)

		@OptionGroup
		private var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			do {
				await run(installedApps: try await installedApps, searcher: ITunesSearchAppStoreSearcher())
			} catch {
				printer.error(error: error)
			}
		}

		func run(installedApps: [InstalledApp], searcher: some AppStoreSearcher) async {
			for appID in requiredAppIDsOptionGroup.appIDs {
				do {
					try await downloadApp(
						withADAMID: try await appID.adamID(searcher: searcher),
						forceDownload: forceOptionGroup.force,
						installedApps: installedApps
					)
				} catch {
					printer.error(error: error)
				}
			}
		}
	}
}
