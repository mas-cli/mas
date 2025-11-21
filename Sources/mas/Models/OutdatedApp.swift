//
// OutdatedApp.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
private import StoreFoundation
private import Version

typealias OutdatedApp = (
	installedApp: InstalledApp,
	newVersion: String
)

private extension InstalledApp {
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

extension [InstalledApp] {
	func outdated(appCatalog: some AppCatalog, shouldWarnIfAppUnknown: Bool) async -> [OutdatedApp] {
		await compactMap { installedApp in
			do {
				let catalogApp = try await appCatalog.lookup(appID: .adamID(installedApp.adamID))
				if installedApp.isOutdated(comparedTo: catalogApp) {
					return OutdatedApp(installedApp, catalogApp.version)
				}
			} catch {
				error.printProblem(shouldWarnIfAppUnknown: shouldWarnIfAppUnknown, expectedAppName: installedApp.name)
			}
			return nil
		}
	}
}
