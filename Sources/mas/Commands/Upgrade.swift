//
// Upgrade.swift
// mas
//
// Created by Andrew Naylor on 2015-12-30.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Command which upgrades apps with new versions available in the Mac App Store.
	struct Upgrade: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Upgrade outdated app(s) installed from the Mac App Store"
		)

		@Flag(help: "Display warnings about apps unknown to the Mac App Store")
		var verbose = false

		@Argument(help: ArgumentHelp("App ID/app name", valueName: "app-id-or-name"))
		var appIDOrNames = [String]()

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			let apps = await findOutdatedApps(installedApps: installedApps, searcher: searcher)

			guard !apps.isEmpty else {
				return
			}

			printInfo(
				"Upgrading ",
				apps.count,
				" outdated application",
				apps.count > 1 ? "s:\n" : ":\n",
				apps.map { installedApp, storeApp in
					"\(storeApp.trackName) (\(installedApp.version)) -> (\(storeApp.version))"
				}
				.joined(separator: "\n"),
				separator: ""
			)

			do {
				try await downloadApps(withAppIDs: apps.map(\.storeApp.trackId))
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.downloadFailed(error: error as NSError)
			}
		}

		private func findOutdatedApps(
			installedApps: [InstalledApp],
			searcher: AppStoreSearcher
		) async -> [(installedApp: InstalledApp, storeApp: SearchResult)] {
			let apps = appIDOrNames.isEmpty // swiftformat:disable:next indent
			? installedApps
			: appIDOrNames.flatMap { appIDOrName in
				if let appID = AppID(appIDOrName) {
					// Argument is an AppID, lookup apps by id using argument
					let installedApps = installedApps.filter { $0.id == appID }
					if installedApps.isEmpty {
						printError(appID.unknownMessage)
					}
					return installedApps
				}

				// Argument is not an AppID, lookup apps by name using argument
				let installedApps = installedApps.filter { $0.name == appIDOrName }
				if installedApps.isEmpty {
					printError("Unknown app name '", appIDOrName, "'", separator: "")
				}
				return installedApps
			}

			var outdatedApps = [(InstalledApp, SearchResult)]()
			for installedApp in apps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						outdatedApps.append((installedApp, storeApp))
					}
				} catch let MASError.unknownAppID(unknownAppID) {
					if verbose {
						printWarning(
							"Identifier ",
							unknownAppID,
							" not found in store. Was expected to identify ",
							installedApp.name,
							".",
							separator: ""
						)
					}
				} catch {
					printError(error)
				}
			}
			return outdatedApps
		}
	}
}
