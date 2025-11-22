//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the App Store.
	struct Outdated: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the App Store"
		)

		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async {
			do {
				await run(installedApps: try await nonTestFlightInstalledApps)
			} catch {
				printer.error(error: error)
			}
		}

		func run(installedApps: [InstalledApp]) async {
			await withTaskGroup(of: Void.self) { group in
				for installedApp in installedApps.filter(by: optionalAppIDsOptionGroup) {
					group.addTask {
						do {
							try await downloadApp(withADAMID: installedApp.adamID) { download, shouldOutput in
								if shouldOutput, let metadata = download.metadata, installedApp.version != metadata.bundleVersion {
									printer.info(
										installedApp.adamID,
										" ",
										installedApp.name,
										" (",
										installedApp.version,
										" -> ",
										metadata.bundleVersion ?? "unknown",
										")",
										separator: ""
									)
								}
								return true
							}
						} catch {
							printer.error(error: error)
						}
					}
				}
			}
		}
	}
}
