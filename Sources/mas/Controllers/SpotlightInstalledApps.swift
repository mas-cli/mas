//
//  SpotlightInstalledApps.swift
//  mas
//
//  Created by Ross Goldberg on 2025-04-09.
//  Copyright © 2025 mas-cli. All rights reserved.
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

		do {
			query.searchScopes =
				try FileManager.default
				.contentsOfDirectory(at: URL(fileURLWithPath: "/Volumes"), includingPropertiesForKeys: [])
				.compactMap { url in
					let applicationsURL = url.appendingPathComponent("Applications")
					return applicationsURL.hasDirectoryPath
						? applicationsURL
						: nil
				}
		} catch {
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
					returning:
						query.results
						.compactMap { result in
							if let item = result as? NSMetadataItem {
								// swift-format-ignore
								InstalledApp(
									id:
										item.value(forAttribute: "kMDItemAppStoreAdamID") as? AppID ?? 0,
									name:
										(item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
										.removingSuffix(".app"),
									bundleID:
										item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String ?? "",
									path:
										item.value(forAttribute: NSMetadataItemPathKey) as? String ?? "",
									version:
										item.value(forAttribute: NSMetadataItemVersionKey) as? String ?? ""
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
		hasSuffix(suffix)
			? Self(dropLast(suffix.count))
			: self
	}
}
