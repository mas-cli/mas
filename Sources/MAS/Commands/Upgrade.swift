//
// Upgrade.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Upgrades outdated apps installed from the Mac App Store.
	struct Upgrade: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Upgrade outdated apps installed from the Mac App Store"
		)

		@OptionGroup
		var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			try await MAS.run { printer in
				await run(downloader: Downloader(printer: printer), installedApps: installedApps, searcher: searcher)
			}
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			let installedApps =
				await findOutdatedApps(printer: downloader.printer, installedApps: installedApps, searcher: searcher)
			guard !installedApps.isEmpty else {
				return
			}

			downloader.printer.info(
				"Upgrading ",
				installedApps.count,
				" outdated application",
				installedApps.count > 1 ? "s:\n" : ":\n",
				installedApps.map { installedApp, storeApp in
					"\(storeApp.trackName) (\(installedApp.version)) -> (\(storeApp.version))"
				}
				.joined(separator: "\n"),
				separator: ""
			)

			for adamID in installedApps.map(\.storeApp.adamID) {
				do {
					try await downloader.downloadApp(withADAMID: adamID)
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}

		private func findOutdatedApps(
			printer: Printer,
			installedApps: [InstalledApp],
			searcher: AppStoreSearcher
		) async -> [(installedApp: InstalledApp, storeApp: SearchResult)] {
			let apps = optionalAppIDsOptionGroup.appIDStrings.isEmpty
			? installedApps // swiftformat:disable:this indent
			: optionalAppIDsOptionGroup.appIDStrings.flatMap { appIDString in
				let appID = AppID(from: appIDString, forceBundleID: optionalAppIDsOptionGroup.forceBundleID)
				let installedApps = installedApps.filter { appID.matches($0) }
				if installedApps.isEmpty {
					printer.error(appID.notInstalledMessage)
				}
				return installedApps
			}

			var outdatedApps = [(InstalledApp, SearchResult)]()
			for installedApp in apps {
				do {
					let storeApp = try await searcher.lookup(appID: .adamID(installedApp.adamID))
					if installedApp.isOutdated(comparedTo: storeApp) {
						outdatedApps.append((installedApp, storeApp))
					}
				} catch {
					verboseOptionGroup.printProblem(forError: error, expectedAppName: installedApp.name, printer: printer)
				}
			}
			return outdatedApps
		}
	}
}
