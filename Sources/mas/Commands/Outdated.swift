//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Atomics
private import Foundation
private import StoreFoundation

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the App Store.
	struct Outdated: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the App Store"
		)

		@OptionGroup
		private var accurateOptionGroup: AccurateOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup

		func run() async {
			await accurateOptionGroup.run(
				accurate: { shouldIgnoreUnknownApps in
					await accurate(
						installedApps: try await nonTestFlightInstalledApps,
						appCatalog: ITunesSearchAppCatalog(),
						shouldIgnoreUnknownApps: shouldIgnoreUnknownApps
					)
				},
				inaccurate: {
					await inaccurate(installedApps: try await nonTestFlightInstalledApps, appCatalog: ITunesSearchAppCatalog())
				}
			)
		}

		private func accurate(
			installedApps: [InstalledApp],
			appCatalog: some AppCatalog,
			shouldIgnoreUnknownApps: Bool
		) async {
			await withTaskGroup(of: OutdatedApp?.self, returning: [OutdatedApp].self) { group in
				let installedApps = await installedApps
				.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable:this indent
				.filter(if: shouldIgnoreUnknownApps, appCatalog: appCatalog, shouldWarnIfAppUnknown: verboseOptionGroup.verbose)
				let maxConcurrentTaskCount = min(installedApps.count, 16) // swiftformat:disable:previous indent
				var index = 0
				while index < maxConcurrentTaskCount {
					let installedApp = installedApps[index]
					index += 1
					group.addTask {
						await installedApp.outdated
					}
				}

				return await group.reduce(into: [OutdatedApp]()) { outdatedApps, outdatedApp in
					if let outdatedApp {
						outdatedApps.append(outdatedApp)
					}

					guard index < installedApps.count else {
						return
					}

					let installedApp = installedApps[index]
					index += 1
					_ = group.addTaskUnlessCancelled { await installedApp.outdated }
				}
			}
			.sorted { $0.installedApp.name.localizedStandardCompare($1.installedApp.name) == .orderedAscending }
			.printOutdatedMessages()
		}

		private func inaccurate(installedApps: [InstalledApp], appCatalog: some AppCatalog) async {
			await installedApps
			.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable indent
			.outdated(appCatalog: appCatalog, shouldWarnIfAppUnknown: verboseOptionGroup.verbose)
			.printOutdatedMessages()
		} // swiftformat:enable indent
	}
}

private extension InstalledApp {
	var outdated: OutdatedApp? {
		get async {
			await withCheckedContinuation { continuation in
				Task {
					let alreadyResumed = ManagedAtomic(false)
					do {
						try await downloadApp(withADAMID: adamID) { download, shouldOutput in
							if shouldOutput, let metadata = download.metadata, version != metadata.bundleVersion {
								if !alreadyResumed.exchange(true, ordering: .acquiringAndReleasing) {
									continuation.resume(returning: OutdatedApp(self, metadata.bundleVersion ?? "unknown"))
								}
							}
							return true
						}
					} catch {
						MAS.printer.error(error: error)
					}
					if !alreadyResumed.load(ordering: .acquiring) {
						continuation.resume(returning: nil)
					}
				}
			}
		}
	}
}

private extension [OutdatedApp] {
	func printOutdatedMessages() {
		MAS.printer.info(map { "\($0.adamID) \($0.name) (\($0.version) -> \($1))" }.joined(separator: "\n"))
	}
}
