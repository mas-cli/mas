//
// Lucky.swift
// mas
//
// Created by Pablo Varela on 2017-05-11.
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Command which installs the first search result.
	///
	/// This is handy as many MAS titles can be long with embedded keywords.
	struct Lucky: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: """
				Install the first app returned from searching the Mac App Store
				(app must have been previously purchased)
				"""
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@Argument(help: "Search term")
		var searchTerm: [String]

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			do {
				let results = try await searcher.search(for: searchTerm.joined(separator: " "))
				guard let result = results.first else {
					throw MASError.noSearchResultsFound
				}

				try await install(appID: result.trackId, installedApps: installedApps)
			} catch {
				throw MASError(searchFailedError: error)
			}
		}

		/// Installs an app.
		///
		/// - Parameters:
		///   - appID: App ID.
		///   - installedApps: List of installed apps.
		/// - Throws: Any error that occurs while attempting to install the app.
		private func install(appID: AppID, installedApps: [InstalledApp]) async throws {
			if let appName = installedApps.first(where: { $0.id == appID })?.name, !forceOptionGroup.force {
				printWarning(appName, "is already installed")
			} else {
				do {
					try await downloadApps(withAppIDs: [appID])
				} catch {
					throw MASError(downloadFailedError: error)
				}
			}
		}
	}
}
