//
// SpotlightInstalledApps.swift
// mas
//
// Created by Ross Goldberg on 2025-04-09.
// Copyright © 2025 mas-cli. All rights reserved.
//

import Foundation

@MainActor // swiftlint:disable:next attributes
var installedApps: [InstalledApp] {
	get async {
		var observer: NSObjectProtocol?
		defer {
			if let observer {
				NotificationCenter.default.removeObserver(observer)
			}
		}

		let query = NSMetadataQuery()
		query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")
		if let volume = UserDefaults(suiteName: "com.apple.appstored")?.dictionary(forKey: "PreferredVolume")?["name"] {
			query.searchScopes = ["/Applications", "/Volumes/\(volume)/Applications"]
		} else {
			query.searchScopes = ["/Applications"]
		}

		return await withCheckedContinuation { continuation in
			observer = NotificationCenter.default.addObserver(
				forName: .NSMetadataQueryDidFinishGathering,
				object: query,
				queue: nil
			) { notification in
				guard let query = notification.object as? NSMetadataQuery else {
					continuation.resume(returning: [])
					return
				}

				query.stop()

				continuation.resume(
					returning: query.results
						.compactMap { result in
							if let item = result as? NSMetadataItem {
								InstalledApp(
									id: item.value(forAttribute: "kMDItemAppStoreAdamID") as? AppID ?? 0,
									name: (item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
										.removingSuffix(".app"),
									bundleID: item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String ?? "",
									path: item.value(forAttribute: NSMetadataItemPathKey) as? String ?? "",
									version: item.value(forAttribute: NSMetadataItemVersionKey) as? String ?? ""
								)
							} else {
								nil
							}
						}
						.sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
				)
			}

			query.start()
		}
	}
}

private extension String {
	func removingSuffix(_ suffix: Self) -> Self {
		// swift-format-ignore
		// swiftformat:disable indent
		hasSuffix(suffix)
		? Self(dropLast(suffix.count))
		: self
		// swiftformat:enable indent
	}
}
