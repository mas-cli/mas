//
// SpotlightInstalledApps.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation

private var applicationsFolder: String { "/Applications" }

@MainActor
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
			query.searchScopes = [applicationsFolder, "/Volumes/\(volume)\(applicationsFolder)"]
		} else {
			query.searchScopes = [applicationsFolder]
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
					returning: query.results.compactMap { result in
						if let item = result as? NSMetadataItem {
							InstalledApp(
								id: item.value(forAttribute: "kMDItemAppStoreAdamID") as? AppID ?? 0,
								bundleID: item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String ?? "",
								name: (item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "").removingSuffix(
									".app"
								),
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
		hasSuffix(suffix) // swiftformat:disable:next indent
		? Self(dropLast(suffix.count))
		: self
	}
}
