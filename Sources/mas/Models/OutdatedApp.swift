//
// OutdatedApp.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Atomics
private import Foundation
private import StoreFoundation

typealias OutdatedApp = (
	installedApp: InstalledApp,
	newVersion: String,
)

private extension Error {
	func print(forExpectedAppName appName: String, shouldWarnIfUnknownApp: Bool) {
		guard let error = self as? MASError, case MASError.unknownAppID = error else {
			MAS.printer.error(error: self)
			return
		}

		if shouldWarnIfUnknownApp {
			MAS.printer.warning(self, "; was expected to identify: ", appName, separator: "")
		}
	}
}

private extension InstalledApp {
	var outdated: OutdatedApp? {
		get async {
			await withCheckedContinuation { continuation in
				Task {
					let alreadyResumed = ManagedAtomic(false)
					do {
						try await AppStore.install.app(withADAMID: adamID) { appStoreVersion, shouldOutput in
							if
								shouldOutput,
								let appStoreVersion,
								version != appStoreVersion,
								!alreadyResumed.exchange(true, ordering: .acquiringAndReleasing)
							{
								continuation.resume(returning: OutdatedApp(self, appStoreVersion))
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

	/// Determines whether the app is considered outdated.
	///
	/// Updates that require a higher macOS version are excluded.
	///
	/// - Parameter catalogApp: `CatalogApp` against which to compare `self`.
	/// - Returns: `true` if `self` is outdated; `false` otherwise.
	func isOutdated(comparedTo catalogApp: CatalogApp) -> Bool {
		SemVerInt(from: catalogApp.minimumOSVersion).flatMap { minimumOSVersion in
			ProcessInfo.processInfo.isOperatingSystemAtLeast(
				OperatingSystemVersion(
					majorVersion: minimumOSVersion.majorInteger,
					minorVersion: minimumOSVersion.minorInteger,
					patchVersion: minimumOSVersion.patchInteger,
				),
			)
			? nil // swiftformat:disable:this indent
			: false
		}
		?? ( // swiftformat:disable indent
			UniversalSemVer(from: version).compareSemVerAndBuild(to: UniversalSemVer(from: catalogApp.version))
			== .orderedAscending
		)
	} // swiftformat:enable indent
}

private extension [InstalledApp] {
	func filterOutApps(
		unknownTo lookupAppFromAppID: (AppID) async throws -> CatalogApp,
		if shouldFilter: Bool,
		shouldWarnIfUnknownApp: Bool,
	) async -> Self {
		!shouldFilter
		? self // swiftformat:disable:this indent
		: await compactMap { installedApp in
			do {
				_ = try await lookupAppFromAppID(.adamID(installedApp.adamID))
				return installedApp
			} catch {
				error.print(forExpectedAppName: installedApp.name, shouldWarnIfUnknownApp: shouldWarnIfUnknownApp)
				return nil
			}
		}
	}
}

func outdatedApps(
	installedApps: [InstalledApp],
	lookupAppFromAppID: (AppID) async throws -> CatalogApp,
	accurateOptionGroup: AccurateOptionGroup,
	verboseOptionGroup: VerboseOptionGroup,
	optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup,
) async -> [OutdatedApp] {
	await accurateOptionGroup.outdatedApps(
		accurate: { shouldIgnoreUnknownApps in
			await withTaskGroup { group in
				let installedApps = await installedApps
				.filter(for: optionalAppIDsOptionGroup.appIDs) // swiftformat:disable indent
				.filterOutApps(
					unknownTo: lookupAppFromAppID,
					if: shouldIgnoreUnknownApps,
					shouldWarnIfUnknownApp: verboseOptionGroup.verbose,
				)
				let maxConcurrentTaskCount = min(installedApps.count, 16) // swiftformat:enable indent
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
			.sorted(using: KeyPathComparator(\.installedApp.name, comparator: .localizedStandard))
		},
		inaccurate: {
			await installedApps
			.filter(for: optionalAppIDsOptionGroup.appIDs) // swiftformat:disable indent
			.compactMap { installedApp in
				do {
					let catalogApp = try await lookupAppFromAppID(.adamID(installedApp.adamID))
					if installedApp.isOutdated(comparedTo: catalogApp) {
						return OutdatedApp(installedApp, catalogApp.version)
					}
				} catch {
					error.print(forExpectedAppName: installedApp.name, shouldWarnIfUnknownApp: verboseOptionGroup.verbose)
				}
				return nil
			}
		}, // swiftformat:enable indent
	)
}
