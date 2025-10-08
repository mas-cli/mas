//
// SpotlightInstalledApps.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
private import ObjectiveC

private var applicationsFolder: String { "/Applications" }

@MainActor
var installedApps: [InstalledApp] {
	get async {
		var observer: (any NSObjectProtocol)?
		defer {
			if let observer {
				NotificationCenter.default.removeObserver(observer)
			}
		}

		let query = NSMetadataQuery()
		query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")
		query.searchScopes =
			if let volume = UserDefaults(suiteName: "com.apple.appstored")?.dictionary(forKey: "PreferredVolume")?["name"] {
				[applicationsFolder, "/Volumes/\(volume)\(applicationsFolder)"]
			} else {
				[applicationsFolder]
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
					.compactMap { result in // swiftformat:disable indent
						if let item = result as? NSMetadataItem {
							InstalledApp(
								adamID: item.value(forAttribute: "kMDItemAppStoreAdamID") as? ADAMID ?? 0,
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
					.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } // swiftformat:enable indent
				)
			}

			query.start()
		}
	}
}

private extension String {
	func removingSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix)
		? Self(dropLast(suffix.count)) // swiftformat:disable:this indent
		: self
	}
}
