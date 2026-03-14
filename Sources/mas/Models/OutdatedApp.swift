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

extension [InstalledApp] {
	func outdatedApps(
		filterFor appIDs: [AppID], // swiftlint:disable:next unneeded_escaping
		lookupAppFromAppID: @escaping @Sendable (AppID) async throws -> CatalogApp,
		accuracy: OutdatedAccuracy,
		shouldCheckMinimumOSVersion: Bool,
		shouldWarnIfUnknownApp: Bool,
	) async -> [OutdatedApp] {
		@Sendable
		func installableCatalogApp(from installedApp: InstalledApp) async -> CatalogApp? {
			do {
				let catalogApp = try await lookupAppFromAppID(.bundleID(installedApp.bundleID))
				return shouldCheckMinimumOSVersion // swiftformat:disable indent
				&& UniversalSemVerInt(from: catalogApp.minimumOSVersion).flatMap { minimumOSVersion in
					ProcessInfo.processInfo.isOperatingSystemAtLeast(
						OperatingSystemVersion(
							majorVersion: minimumOSVersion.majorInteger,
							minorVersion: minimumOSVersion.minorInteger,
							patchVersion: minimumOSVersion.patchInteger,
						),
					)
				}
				== false ? nil : catalogApp
			} catch { // swiftformat:enable indent
				if let error = error as? MASError, case MASError.unknownAppID = error {
					if shouldWarnIfUnknownApp {
						MAS.printer.warning(error, "; was expected to identify: ", installedApp.name, separator: "")
					}
				} else {
					MAS.printer.error(error: error)
				}
				return nil
			}
		}

		return await filter(for: appIDs).concurrentCompactMap(
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
										continuation.resume(returning: OutdatedApp(installedApp, appStoreVersion))
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
					UniversalSemVer(from: installedApp.version).compareSemVerAndBuild(to: .init(from: catalogApp.version))
					== .orderedAscending ? OutdatedApp(installedApp, catalogApp.version) : nil
				}
			},
		) // swiftformat:enable indent
	}
}
