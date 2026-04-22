//
// OutdatedAppOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Atomics
private import Foundation

struct OutdatedAppOptionGroup: ParsableArguments {
	@Flag
	private var accuracy = OutdatedAccuracy.inaccurate // swiftformat:disable:this organizeDeclarations
	@Flag(
		name: .customLong("check-min-os"),
		inversion: .prefixedNo,
		help: "Check if macOS can install latest app version",
	)
	private var shouldCheckMinimumOSVersion = true // swiftformat:disable:this organizeDeclarations
	@Flag(name: .customLong("verbose"), help: "Warn about app IDs unknown to the App Store")
	private var shouldWarnIfUnknownApp = false // swiftformat:disable:this organizeDeclarations
	@OptionGroup
	var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

	func outdatedApps(from installedApps: [InstalledApp]) async -> [OutdatedApp] {
		@Sendable
		func installableCatalogApp(from installedApp: InstalledApp) async -> CatalogApp? {
			do {
				let catalogApp = try await Dependencies.current.lookupAppFromAppID(.bundleID(installedApp.bundleID))
				return shouldCheckMinimumOSVersion // swiftformat:disable indent
				&& UniversalSemVerInt(rawValue: catalogApp.minimumOSVersion).map { minimumOSVersion in
					ProcessInfo.processInfo.isOperatingSystemAtLeast(
						.init(
							majorVersion: minimumOSVersion.majorInteger,
							minorVersion: minimumOSVersion.minorInteger,
							patchVersion: minimumOSVersion.patchInteger,
						),
					)
				}
				== false ? nil : catalogApp
			} catch { // swiftformat:enable indent
				if case MASError.unknownAppID = error {
					if shouldWarnIfUnknownApp {
						MAS.printer.warning(error, "; was expected to identify: ", installedApp.name, separator: "")
					}
				} else {
					MAS.printer.error(error: error)
				}
				return nil
			}
		}

		return await installedApps.filter(for: installedAppIDsOptionGroup.appIDs).concurrentCompactMap(
			accuracy == .accurate
			? { @Sendable installedApp in // swiftformat:disable indent
				if shouldCheckMinimumOSVersion, await installableCatalogApp(from: installedApp) == nil {
					nil
				} else {
					await withCheckedContinuation { continuation in
						Task {
							let alreadyResumed = ManagedAtomic(false)
							do {
								try await AppStore.install.app(withADAMID: installedApp.adamID) { appStoreVersion, shouldOutput in
									if
										shouldOutput,
										let appStoreVersion,
										installedApp.version != appStoreVersion,
										!alreadyResumed.exchange(true, ordering: .acquiringAndReleasing)
									{
										continuation.resume(returning: (installedApp, appStoreVersion))
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
			: { @Sendable installedApp in
				await installableCatalogApp(from: installedApp).flatMap { catalogApp in
					UniversalSemVer(rawValue: installedApp.version).compareSemVerAndBuild(to: .init(rawValue: catalogApp.version))
					== .orderedAscending ? (installedApp, catalogApp.version) : nil
				}
			},
		) // swiftformat:enable indent
	}
}

typealias OutdatedApp = (
	installedApp: InstalledApp,
	newVersion: String,
)
