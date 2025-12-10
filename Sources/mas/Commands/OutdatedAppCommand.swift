//
// OutdatedAppCommand.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Atomics
private import Foundation
private import StoreFoundation
private import Version

protocol OutdatedAppCommand: AsyncParsableCommand, Sendable {
	var accurateOptionGroup: AccurateOptionGroup { get }
	var verboseOptionGroup: VerboseOptionGroup { get }
	var optionalAppIDsOptionGroup: OptionalAppIDsOptionGroup { get }

	func outdatedApps(installedApps: [InstalledApp], appCatalog: some AppCatalog) async -> [OutdatedApp]
	func process(_ outdatedApps: [OutdatedApp]) async throws
}

extension OutdatedAppCommand { // swiftlint:disable:this file_types_order
	func run() async throws {
		try await run(installedApps: try await nonTestFlightInstalledApps, appCatalog: ITunesSearchAppCatalog())
	}

	private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
		try await process(await outdatedApps(installedApps: installedApps, appCatalog: appCatalog))
	}
}

extension OutdatedAppCommand { // swiftlint:disable:this file_types_order
	func outdatedAppsDefault(installedApps: [InstalledApp], appCatalog: some AppCatalog) async -> [OutdatedApp] {
		await accurateOptionGroup.outdatedApps(
			accurate: { shouldIgnoreUnknownApps in
				await withTaskGroup(of: OutdatedApp?.self, returning: [OutdatedApp].self) { group in
					let installedApps = await installedApps
					.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable indent
					.filterOutApps(
						unknownTo: appCatalog,
						if: shouldIgnoreUnknownApps,
						shouldWarnIfUnknownApp: verboseOptionGroup.verbose
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
				.sorted { $0.installedApp.name.localizedStandardCompare($1.installedApp.name) == .orderedAscending }
			},
			inaccurate: {
				await installedApps
				.filter(by: optionalAppIDsOptionGroup) // swiftformat:disable indent
				.outdated(appCatalog: appCatalog, shouldWarnIfUnknownApp: verboseOptionGroup.verbose)
			}
		)
	}
}

typealias OutdatedApp = (
	installedApp: InstalledApp,
	newVersion: String
)

private extension InstalledApp {
	var outdated: OutdatedApp? {
		get async {
			await withCheckedContinuation { continuation in
				Task {
					let alreadyResumed = ManagedAtomic(false)
					do {
						try await AppStore.install.app(withADAMID: adamID) { download, shouldOutput in
							if
								shouldOutput,
								let metadata = download.metadata,
								version != metadata.bundleVersion,
								!alreadyResumed.exchange(true, ordering: .acquiringAndReleasing)
							{
								continuation.resume(returning: OutdatedApp(self, metadata.bundleVersion ?? "unknown"))
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
		if let minimumOSVersion = Version(tolerant: catalogApp.minimumOSVersion) {
			guard
				ProcessInfo.processInfo.isOperatingSystemAtLeast(
					OperatingSystemVersion(
						majorVersion: minimumOSVersion.major,
						minorVersion: minimumOSVersion.minor,
						patchVersion: minimumOSVersion.patch
					)
				)
			else {
				return false
			}
		}

		return if
			let installedSemanticVersion = Version(tolerant: version),
			let catalogSemanticVersion = Version(tolerant: catalogApp.version)
		{
			installedSemanticVersion < catalogSemanticVersion
		} else {
			version != catalogApp.version
		}
	}
}

private extension [InstalledApp] {
	func filterOutApps(
		unknownTo appCatalog: some AppCatalog,
		if shouldFilter: Bool,
		shouldWarnIfUnknownApp: Bool
	) async -> Self {
		shouldFilter
		? await compactMap { installedApp in // swiftformat:disable indent
			do {
				_ = try await appCatalog.lookup(appID: .adamID(installedApp.adamID))
				return installedApp
			} catch {
				error.print(forExpectedAppName: installedApp.name, shouldWarnIfUnknownApp: shouldWarnIfUnknownApp)
				return nil
			}
		}
		: self
	} // swiftformat:enable indent

	func outdated(appCatalog: some AppCatalog, shouldWarnIfUnknownApp: Bool) async -> [OutdatedApp] {
		await compactMap { installedApp in
			do {
				let catalogApp = try await appCatalog.lookup(appID: .adamID(installedApp.adamID))
				if installedApp.isOutdated(comparedTo: catalogApp) {
					return OutdatedApp(installedApp, catalogApp.version)
				}
			} catch {
				error.print(forExpectedAppName: installedApp.name, shouldWarnIfUnknownApp: shouldWarnIfUnknownApp)
			}
			return nil
		}
	}
}

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
