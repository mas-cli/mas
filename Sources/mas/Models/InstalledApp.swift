//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Foundation
private import Version

struct InstalledApp: Hashable, Sendable {
	let id: AppID
	// periphery:ignore
	let bundleID: String
	let name: String
	let path: String
	let version: String
}

extension InstalledApp {
	var idAndName: String {
		"app ID \(id) (\(name))"
	}

	/// Determines whether the app is considered outdated.
	///
	/// Updates that require a higher OS version are excluded.
	///
	/// - Parameter storeApp: App from search result.
	/// - Returns: true if the app is outdated; false otherwise.
	func isOutdated(comparedTo storeApp: SearchResult) -> Bool {
		// If storeApp requires a version of macOS newer than the running version, do not consider self outdated.
		if let osVersion = Version(tolerant: storeApp.minimumOsVersion) {
			let requiredVersion = OperatingSystemVersion(
				majorVersion: osVersion.major,
				minorVersion: osVersion.minor,
				patchVersion: osVersion.patch
			)
			guard ProcessInfo.processInfo.isOperatingSystemAtLeast(requiredVersion) else {
				return false
			}
		}

		// The App Store does not enforce semantic versioning, but we assume most apps follow versioning
		// schemes that increase numerically over time.
		return if
			let semanticBundleVersion = Version(tolerant: version),
			let semanticAppStoreVersion = Version(tolerant: storeApp.version)
		{
			semanticBundleVersion < semanticAppStoreVersion
		} else {
			// If a version string can't be parsed as a Semantic Version, our best effort is to
			// check for equality. The only version that matters is the one in the App Store.
			// https://semver.org
			version != storeApp.version
		}
	}
}
