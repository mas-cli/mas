//
// Install.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs one or more apps you have previously acquired from the Mac App Store.
	///
	/// This command downloads and installs apps based on their App Store ID.
	/// You can find app IDs using the `mas search` command or from the App Store URL.
	///
	/// By default, if the app is already installed, it will be skipped.
	/// Use `--force` to reinstall an already installed app.
	///
	/// Example:
	/// ```bash
	/// mas install 497799835
	/// ```
	///
	/// Output:
	/// ```
	/// ==> Downloading Xcode
	/// ==> Installed Xcode
	/// ```
	///
	/// > Tip:
	/// > Use `mas list` to check installed apps, and `mas outdated` to find available updates.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously purchased apps from the Mac App Store"
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			try await mas.run { printer in
				await run(downloader: Downloader(printer: printer), installedApps: installedApps, searcher: searcher)
			}
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			for appID in appIDsOptionGroup.appIDs.filter({ appID in
				if let installedApp = installedApps.first(where: { $0.id == appID }), !forceOptionGroup.force {
					downloader.printer.warning("Already installed:", installedApp.idAndName)
					return false
				}
				return true
			}) {
				do {
					_ = try await searcher.lookup(appID: appID)
					try await downloader.downloadApp(withAppID: appID)
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}
	}
}
