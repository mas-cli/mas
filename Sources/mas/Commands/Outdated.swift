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
				let installedApps = installedApps.filter(by: optionalAppIDsOptionGroup)
				let maxConcurrentTaskCount = min(installedApps.count, 16)
				var index = 0
				while index < maxConcurrentTaskCount {
					let installedApp = installedApps[index]
					index += 1
					group.addTask {
						await installedApp.outputMessageIfOutdated()
					}
				}

				for await _ in group {
					guard index < installedApps.count else {
						break
					}

					let installedApp = installedApps[index]
					index += 1
					if !group.addTaskUnlessCancelled(operation: { await installedApp.outputMessageIfOutdated() }) {
						break
					}
				}
			}
		}
	}
}

private extension InstalledApp {
	func outputMessageIfOutdated() async {
		do {
			try await downloadApp(withADAMID: adamID) { download, shouldOutput in
				if shouldOutput, let metadata = download.metadata, version != metadata.bundleVersion {
					outputOutdatedMessage(newVersion: metadata.bundleVersion)
				}
				return true
			}
		} catch {
			MAS.printer.error(error: error)
		}
	}

	private func outputOutdatedMessage(newVersion: String?) {
		MAS.printer.info(adamID, " ", name, " (", version, " -> ", newVersion ?? "unknown", ")", separator: "")
	}
}
